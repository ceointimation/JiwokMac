/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailstream.h,v 1.18 2007/01/28 16:00:18 hoa Exp $
 */

#ifndef MAILSTREAM_H

#define MAILSTREAM_H

#ifndef _MSC_VER
#	include <sys/time.h>
#endif

#include "mailstream_low.h"
#include "mailstream_helper.h"
#include "mailstream_socket.h"
#include "mailstream_ssl.h"
#include "mailstream_types.h"

#ifdef __cplusplus
extern "C" {
#endif

mailstream * mailstream_new(mailstream_low * low, size_t buffer_size);
ssize_t mailstream_write(mailstream * s, const void * buf, size_t count);
ssize_t mailstream_read(mailstream * s, void * buf, size_t count);
int mailstream_close(mailstream * s);
int mailstream_flush(mailstream * s);
ssize_t mailstream_feed_read_buffer(mailstream * s);

LIBETPAN_EXPORT
mailstream_low * mailstream_get_low(mailstream * s);

LIBETPAN_EXPORT
void mailstream_set_low(mailstream * s, mailstream_low * low);
void mailstream_cancel(mailstream * s);

#ifdef LIBETPAN_MAILSTREAM_DEBUG
LIBETPAN_EXPORT
extern int mailstream_debug;

/* direction is 1 for send, 0 for receive, -1 when it does not apply */
LIBETPAN_EXPORT
extern void (* mailstream_logger)(int direction,
    const char * str, size_t size);
#endif

#define LIBETPAN_MAILSTREAM_NETWORK_DELAY
LIBETPAN_EXPORT
extern struct timeval mailstream_network_delay;

#ifdef __cplusplus
}
#endif

#endif

