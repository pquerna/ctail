/*
 *  Copyright 2007 Paul Querna
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#include <apr.h>
#include <apr_general.h>
#include <apr_getopt.h>
#include <apr_strings.h>
#include <apr_file_io.h>
#include <apr_thread_proc.h>
#include <apr_poll.h>
#include <apr_version.h>

#include <apr_buckets.h>

#include "ctail_version.h"

#include <stdlib.h>

static const apr_getopt_option_t g_arg_options[] = {
    // long name, short name, argc, help string
    {"help", 'h', 0, "Show Help"},
    {"debug", 'd', 0, "Show extra debuging information"},
#ifdef ENABLE_CUSTOM_CMD
    {"ssh", 's', 1, "Use Custom ssh Command"},
    {"tail", 't', 1, "Use Custom tail Command"},
#endif
    {"machines", 'm', 1, "Space seperated machine list"},
    {"file", 'f', 1, "Default target file to tail"},
    {"prefix", 'p', 0, "Prefix everyline with the source machine name"},
    {"bulk", 'b', 0, "Enable IO buffering, recommended for busy clusters."},
    {0, 0, 0, 0}
};

typedef struct ctail_machine_t
{
    apr_pool_t *p;
    int alive;
    const char *host;
    const char *path;
    apr_procattr_t *procattr;
    apr_proc_t child;
    apr_pollfd_t pollfd;
    apr_bucket_brigade *bbmain;
    apr_bucket_brigade *bbtmp;
} ctail_machine_t;

typedef struct ctail_ctxt_t
{
    apr_pool_t *p;
    apr_file_t *errfile;
    apr_file_t *outfile;
    int debug;
    int show_machine;
    const char *ssh_cmd;
    const char *tail_cmd;
    const char *default_file;
    apr_array_header_t *machines;
    apr_bucket_alloc_t *buckets;
} ctail_ctxt_t;

#ifndef NL
#define NL APR_EOL_STR
#endif

#ifndef CTAIL_DEFAULT_SSH_CMD
#define CTAIL_DEFAULT_SSH_CMD "ssh -q -o BatchMode=yes -o ConnectTimeout=30"
#endif

#ifndef CTAIL_DEFAULT_TAIL_CMD
#define CTAIL_DEFAULT_TAIL_CMD "tail -f"
#endif

/* Ugh. So. APR_VERSION_AT_LEAST was added in 1.3.0. */
#ifndef APR_VERSION_AT_LEAST
#define APR_VERSION_AT_LEAST(major,minor,patch)                    \
(((major) < APR_MAJOR_VERSION)                                     \
 || ((major) == APR_MAJOR_VERSION && (minor) < APR_MINOR_VERSION) \
 || ((major) == APR_MAJOR_VERSION && (minor) == APR_MINOR_VERSION && (patch) <= APR_PATCH_VERSION))
#endif

#if APR_VERSION_AT_LEAST(1, 3, 0)
#define HAVE_IO_BUFFER_ON_STDOUT
#endif

static int create_child(ctail_ctxt_t *ctxt, ctail_machine_t *m)
{
    int argc = 0;
    apr_bucket *e;
    const char *argv[11];
    apr_status_t rv;
    
    apr_pool_create(&m->p, ctxt->p);
    
    rv = apr_procattr_create(&m->procattr, m->p);

    if (rv) {
        apr_file_printf(ctxt->errfile,
                        "ERR: apr_procattr_create: (%d)"NL, rv);
        return EXIT_FAILURE;        
    }

    rv = apr_procattr_io_set(m->procattr,
                             APR_NO_PIPE,
                             APR_FULL_BLOCK,
                             APR_NO_PIPE);
    if (rv) {
        apr_file_printf(ctxt->errfile,
                        "ERR: apr_procattr_io_set: (%d)"NL, rv);
        return EXIT_FAILURE;        
    }
    
    rv = apr_procattr_cmdtype_set(m->procattr,
                                APR_SHELLCMD_ENV);

    if (rv) {
        apr_file_printf(ctxt->errfile,
                        "ERR: apr_procattr_cmdtype_set: (%d)"NL, rv);
        return EXIT_FAILURE;        
    }
    
#ifdef ENABLE_CUSTOM_CMD
#error I never finished support for this. patches welcome?
#else
    argv[argc++] = "/usr/bin/ssh";
    argv[argc++] = "-q";
    argv[argc++] = "-o";
    argv[argc++] = "BatchMode=yes";
    argv[argc++] = "-o";
    argv[argc++] = "ConnectTimeout=30";
    argv[argc++] = m->host;
    argv[argc++] = "tail";
    argv[argc++] = "-f";
    argv[argc++] = m->path;
    argv[argc++] = NULL;
#endif
    
    rv = apr_proc_create(&m->child, argv[0], argv, NULL, 
                         m->procattr, m->p);
    
    if (rv) {
        apr_file_printf(ctxt->errfile,
                        "ERR: apr_proc_create: (%d)"NL, rv);
        return EXIT_FAILURE;        
    }
    
    m->alive = 1;

    m->bbmain = apr_brigade_create(m->p, ctxt->buckets);
    m->bbtmp = apr_brigade_create(m->p, ctxt->buckets);
    e = apr_bucket_pipe_create(m->child.out, ctxt->buckets);
    APR_BRIGADE_INSERT_TAIL(m->bbmain, e);
    
    return 0;
}

static void show_help(ctail_ctxt_t *ct)
{
    /* XXXX: finish me*/
    apr_file_printf(ct->errfile,
                    "ctail " CTAIL_VERSION_STRING NL
                    "Usage: "NL
                    "   ctail (options)"NL
                    "Options:"NL
                    "   -b --bulk               Enable Bulk IO Buffering for output."NL
                    "   -d --debug              Enable debug output."NL
                    "   -h --help               Print this help message."NL
                    "   -f --file=<path>        Sets default target file to tail"NL
                    "   -m --machines=<list>    List of machines to connect to."NL
                    "   -p --prefix             Show machine names before every line."NL
#ifdef ENABLE_CUSTOM_CMD
                    "   -s --ssh=<cmd>          Use a custom ssh command."NL
                    "                           Default: %s" NL
                    "   -t --tail=<cmd>         Use a custom tail command."NL
                    "                           Default: %s" NL
#endif
                    NL
#ifdef ENABLE_CUSTOM_CMD
                    , CTAIL_DEFAULT_SSH_CMD,
                    CTAIL_DEFAULT_TAIL_CMD
#endif
                    );
}

static apr_status_t create_children(ctail_ctxt_t *ctxt)
{
    apr_status_t rv = APR_SUCCESS;
    int i = 0;
    
    for (i = 0;
         i < ctxt->machines->nelts && rv == APR_SUCCESS;
         i++)
    {
        ctail_machine_t *m = ((ctail_machine_t **)ctxt->machines->elts)[i];
        rv = create_child(ctxt, m);
    }
    
    return rv;
}

static int any_machines_alive(ctail_ctxt_t *ctxt)
{
    int i = 0;

    for (i = 0;
         i < ctxt->machines->nelts;
         i++)
    {
        ctail_machine_t *m = ((ctail_machine_t **)ctxt->machines->elts)[i];
        if (m->alive) {
            return 1;
        }
    }

    return 0;
}

static apr_status_t read_line(ctail_ctxt_t *ctxt, ctail_machine_t *m)
{
    struct iovec vec[3];
    int ivec = 0;
    char buf[8000];
    apr_status_t rv;
    apr_size_t len = sizeof(buf);
    apr_size_t nbytes = 0;
    
    rv = apr_brigade_split_line(m->bbtmp, m->bbmain, APR_NONBLOCK_READ, len);

    if (rv != APR_SUCCESS) {
        apr_brigade_cleanup(m->bbtmp);
        return rv;
    }

    rv = apr_brigade_flatten(m->bbtmp, buf, &len);
    if (rv != APR_SUCCESS) {
        apr_brigade_cleanup(m->bbtmp);
        return rv;
    }

    if (len == 0) {
        apr_brigade_cleanup(m->bbtmp);
        return APR_EOF;
    }
    
    if (ctxt->show_machine) {
        vec[ivec].iov_base = (void*)m->host;
        vec[ivec].iov_len = strlen(m->host);
        ivec++;

        vec[ivec].iov_base = (void*)": ";
        vec[ivec].iov_len = 2;
        ivec++;
    }

    vec[ivec].iov_base = buf;
    vec[ivec].iov_len = len;
    ivec++;

    rv = apr_file_writev_full(ctxt->outfile, vec, ivec, &nbytes);

    if (rv) {
        apr_brigade_cleanup(m->bbtmp);
        return rv;
    }
    apr_brigade_cleanup(m->bbtmp);

    return APR_SUCCESS;
}

static apr_status_t listen_to_children(ctail_ctxt_t *ctxt)
{
    apr_status_t rv;
    apr_pollset_t *pollset;
    int i = 0;

    rv = apr_pollset_create(&pollset, ctxt->machines->nelts, ctxt->p, 0);

    if (rv) {
        apr_file_printf(ctxt->errfile,
                        "ERR: apr_pollset_create: %d"NL, rv);
        return rv;
    }

    for (i = 0;
         i < ctxt->machines->nelts && rv == APR_SUCCESS;
         i++)
    {
        ctail_machine_t *m = ((ctail_machine_t **)ctxt->machines->elts)[i];
        m->pollfd.desc_type = APR_POLL_FILE;
        m->pollfd.reqevents = APR_POLLOUT|APR_POLLIN;
        m->pollfd.desc.f = m->child.out;
        m->pollfd.client_data = m;
        rv = apr_pollset_add(pollset, &m->pollfd);
    }

    if (rv) {
        apr_file_printf(ctxt->errfile,
                        "ERR: apr_pollset_add: %d"NL, rv);
    }
    
    do {
        int lrv;
        const apr_pollfd_t *descs = NULL;

        rv = apr_pollset_poll(pollset, -1, &lrv, &descs);

        if (APR_STATUS_IS_EINTR(rv)) {
            continue;
        }
        else if (rv) {
            apr_file_printf(ctxt->errfile,
                            "ERR: apr_pollset_poll: %d"NL, rv);
        }
        
        if (!lrv) {
            continue;
        }
        
        for (i = 0;
             i < lrv;
             i++)
        {
            ctail_machine_t *m = (ctail_machine_t *)(descs[i].client_data);

            do {
                rv = read_line(ctxt, m);
            } while(rv == APR_SUCCESS);
            
            if (rv && !APR_STATUS_IS_EAGAIN(rv)) {
                /* just fail this single machine, not everything. */
                apr_pollset_remove(pollset, &m->pollfd);
                m->alive = 0;
                apr_file_close(m->child.out);
                apr_proc_kill(&m->child, 9);
                if (rv != APR_EOF) {
                    apr_file_printf(ctxt->errfile,
                                    "ERR: read_line on %s:%s: %d"NL,
                                    m->host, m->path, rv);
                }
            }

            rv = APR_SUCCESS;
        }

    } while (rv == APR_SUCCESS && any_machines_alive(ctxt));
    
    apr_pollset_destroy(pollset);
    
    return rv;
}

int main(int argc, const char * const argv[])
{
    apr_status_t rv;
    ctail_ctxt_t ctxt;
    apr_int32_t ioflags = 0;

    rv = apr_initialize();
    if (rv != APR_SUCCESS) {
        fprintf(stderr, "Unable to Initialize APR!"NL);
        return EXIT_FAILURE;
    }

    rv = apr_pool_create(&ctxt.p, NULL);
    if (rv != APR_SUCCESS) {
        fprintf(stderr, "Unable to create Root Pool!"NL);
        return EXIT_FAILURE;
    }

    ctxt.debug = 0;
    ctxt.show_machine = 0;
    ctxt.ssh_cmd = CTAIL_DEFAULT_SSH_CMD;
    ctxt.tail_cmd = CTAIL_DEFAULT_TAIL_CMD;
    ctxt.default_file = NULL;
    ctxt.machines = apr_array_make(ctxt.p, 15, sizeof(ctail_machine_t*));

    apr_file_open_stderr(&ctxt.errfile, ctxt.p);

    {
        apr_getopt_t *opts;
        int optname;
        const char *optarg;
        
        apr_getopt_init(&opts, ctxt.p, argc, argv);
        
        while (1) {
            
            rv = apr_getopt_long(opts, g_arg_options, &optname, &optarg);
            if (APR_STATUS_IS_EOF(rv)) {
                break;
            }
            else if (rv != APR_SUCCESS) {
                apr_file_printf(ctxt.errfile,
                                "Error: Invalid Arguments" NL NL);
                show_help(&ctxt);
                return EXIT_FAILURE;
            }

            switch(optname) 
            {
                case 'h':
                    show_help(&ctxt);
                    return EXIT_SUCCESS;
                case 'd':
                    ctxt.debug = 1;
                    break;
                case 'b':
                    ioflags = APR_BUFFERED;
                    break;
                case 'p':
                    ctxt.show_machine = 1;
                    break;
                case 'f':
                    ctxt.default_file = apr_pstrdup(ctxt.p, optarg);
                    break;
                case 'm':
                {
                    char *cur;
                    char *last;
                    char *line = apr_pstrdup(ctxt.p, optarg);
                    cur = apr_strtok(line, " ", &last);
                    while (cur) {
                        ctail_machine_t *machine = NULL;
                        char *filep = strchr(cur, ':');
                        if (filep) {
                            *filep = '\0';
                            filep++;
                            if (strlen(filep) < 3) {
                                filep = NULL;
                            }
                        }
                        else {
                            filep = NULL;
                        }
                        machine = apr_palloc(ctxt.p, sizeof(ctail_machine_t));
                        (*((ctail_machine_t**)apr_array_push(ctxt.machines))) = machine;
                        machine->host = cur;
                        machine->path = filep;
                        machine->alive = 0;
                        
                        cur = apr_strtok(NULL, " ", &last);
                    }
                    break;
                }
#ifdef ENABLE_CUSTOM_CMD
                case 's':
                    ctxt.ssh_cmd = apr_pstrdup(ctxt.p, optarg);
                    break;
                case 't':
                    ctxt.tail_cmd = apr_pstrdup(ctxt.p, optarg);
                    break;
#endif
                default:
                    apr_file_printf(ctxt.errfile,
                                    "ERR: Invalid parameter passed."NL);
                    show_help(&ctxt);
                    return EXIT_SUCCESS;
            }      
        }
    }

    if (ctxt.machines->nelts < 1) {
        apr_file_printf(ctxt.errfile,
                        "ERR: No machines specified.  Did you forget -m?"NL);
        return EXIT_FAILURE;
    }
    
    {
        int i = 0;
        
        for (i = 0;
             i < ctxt.machines->nelts;
             i++)
        {
            ctail_machine_t *m = ((ctail_machine_t **)ctxt.machines->elts)[i];
            
            if (!m->path && !ctxt.default_file) {
                apr_file_printf(ctxt.errfile,
                                "ERR: No path specified for '%s', and no "
                                "default file (-f) set!"NL,
                                m->host);
                return EXIT_FAILURE;
            }
            
            if (!m->path) {
                m->path = ctxt.default_file;
            }
        }
    }

    /* xxxxx: non-stdout output target */
#ifdef HAVE_IO_BUFFER_ON_STDOUT
    rv = apr_file_open_flags_stdout(&ctxt.outfile, ioflags, ctxt.p);
#else
    if (ioflags != 0) {
        apr_file_printf(ctxt.errfile,
                        "ERR: To use buffered IO on stdout, you must "
                        "have at least APR 1.3.0. Sorry."NL);
        return EXIT_FAILURE;
    }
    rv = apr_file_open_stdout(&ctxt.outfile, ctxt.p);
#endif
    if (rv != APR_SUCCESS) {
        apr_file_printf(ctxt.errfile,
                        "ERR: Unable to open output stdout: %d"NL, rv);
        return EXIT_FAILURE;
    }

    ctxt.buckets = apr_bucket_alloc_create(ctxt.p);

    rv = create_children(&ctxt);
    if (rv != APR_SUCCESS) {
        apr_file_printf(ctxt.errfile,
                        "ERR: Creating children failed: %d"NL, rv);
        return EXIT_FAILURE;
    }

    rv = listen_to_children(&ctxt);
    if (rv != APR_SUCCESS) {
        /* XXXX: improve error messages to include rv string */
        apr_file_printf(ctxt.errfile,
                        "ERR: listening to children failed: %d"NL, rv);
        return EXIT_FAILURE;
    }

    apr_file_close(ctxt.outfile);

    return EXIT_SUCCESS;
}

