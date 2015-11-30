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
 * $Id: maildriver_errors.h,v 1.9 2006/12/13 18:31:32 hoa Exp $
 */

#ifndef MAILDRIVER_ERRORS_H

#define MAILDRIVER_ERRORS_H

enum {
  MAIL_NO_ERROR = 0,
  MAIL_NO_ERROR_AUTHENTICATED,
  MAIL_NO_ERROR_NON_AUTHENTICATED,
  MAIL_ERROR_NOT_IMPLEMENTED,
  MAIL_ERROR_UNKNOWN,
  MAIL_ERROR_CONNECT,
  MAIL_ERROR_BAD_STATE,
  MAIL_ERROR_FILE,
  MAIL_ERROR_STREAM,
  MAIL_ERROR_LOGIN,
  MAIL_ERROR_CREATE, /* 10 */
  MAIL_ERROR_DELETE,
  MAIL_ERROR_LOGOUT,
  MAIL_ERROR_NOOP,
  MAIL_ERROR_RENAME,
  MAIL_ERROR_CHECK,
  MAIL_ERROR_EXAMINE,
  MAIL_ERROR_SELECT,
  MAIL_ERROR_MEMORY,
  MAIL_ERROR_STATUS,
  MAIL_ERROR_SUBSCRIBE, /* 20 */
  MAIL_ERROR_UNSUBSCRIBE,
  MAIL_ERROR_LIST,
  MAIL_ERROR_LSUB,
  MAIL_ERROR_APPEND,
  MAIL_ERROR_COPY,
  MAIL_ERROR_FETCH,
  MAIL_ERROR_STORE,
  MAIL_ERROR_SEARCH,
  MAIL_ERROR_DISKSPACE,
  MAIL_ERROR_MSG_NOT_FOUND,  /* 30 */
  MAIL_ERROR_PARSE,
  MAIL_ERROR_INVAL,
  MAIL_ERROR_PART_NOT_FOUND,
  MAIL_ERROR_REMOVE,
  MAIL_ERROR_FOLDER_NOT_FOUND,
  MAIL_ERROR_MOVE,
  MAIL_ERROR_STARTTLS,
  MAIL_ERROR_CACHE_MISS,
  MAIL_ERROR_NO_TLS,
  MAIL_ERROR_EXPUNGE, /* 40 */
  /* misc errors */
  MAIL_ERROR_MISC,
  MAIL_ERROR_PROTOCOL,
  MAIL_ERROR_CAPABILITY,
  MAIL_ERROR_CLOSE,
  MAIL_ERROR_FATAL,
  MAIL_ERROR_READONLY,
  MAIL_ERROR_NO_APOP,
  MAIL_ERROR_COMMAND_NOT_SUPPORTED,
  MAIL_ERROR_NO_PERMISSION,
  MAIL_ERROR_PROGRAM_ERROR, /* 50 */
  MAIL_ERROR_SUBJECT_NOT_FOUND,
  MAIL_ERROR_CHAR_ENCODING_FAILED,
  MAIL_ERROR_SEND,
  MAIL_ERROR_COMMAND,
  MAIL_ERROR_SYSTEM,
  MAIL_ERROR_UNABLE,
  MAIL_ERROR_FOLDER,
  MAIL_ERROR_SSL
};

#endif