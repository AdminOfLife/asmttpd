;asmttpd - Web server for Linux written in amd64 assembly.
;Copyright (C) 2014  Nathan Torchia <nemasu@gmail.com>
;
;This file is part of asmttpd.
;
;asmttpd is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 2 of the License, or
;(at your option) any later version.
;
;asmttpd is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with asmttpd.  If not, see <http://www.gnu.org/licenses/>.

;Constants
%define FD_STDOUT 0x1
%define THREAD_STACK_SIZE 16384
%define SIGCHILD 0x11 ;SIGCHILD signal constant
%define SIGHUP      1 ;Hangup (POSIX).
%define SIGINT      2 ;Interrupt (ANSI).
%define SIGQUIT     3 ;Quit (POSIX).
%define SIGTERM     15; Default kill signal
%define SA_RESTORER 0x04000000 ;Required for x86_64 sigaction
%define FUTEX_WAIT  0
%define FUTEX_WAKE  1
%define QUEUE_SIZE 1073741824 ; in bytes, 1GB for now xD
%define HUNDRED_MB 104857600 

;Flags
%define MMAP_PROT_READ     0x1
%define MMAP_PROT_WRITE    0x2
%define MMAP_MAP_PRIVATE   0x2
%define MMAP_MAP_ANON      0x20
%define MMAP_MAP_GROWSDOWN 0x100

%define CLONE_VM      0x100   ;Same memory space
%define CLONE_FS      0x200   ;Same file system information
%define CLONE_FILES   0x400   ;Share file descriptors
%define CLONE_SIGHAND 0x800   ;Share signal handlers
%define CLONE_THREAD  0x10000 ;Same thread group ( same process )

%define OPEN_RDONLY    00
%define OPEN_DIRECTORY 0x10000 ; Open will fail if path is not a directory 

%define AF_INET        2
%define SOCK_STREAM    1
%define PROTO_TCP      6

;%define RECV_WAITALL   0x100   

;System Call Values
%define SYS_READ  0  ;int fd, const void *buf, size_t count
%define SYS_WRITE 1  ;int fd, const void *buf, size_t count
%define SYS_MMAP  9  ;void *addr, size_t length, int prot, int flags, int fd, off_t offset
%define SYS_CLONE 56 ;unsigned long clone_flags, unsigned long newsp, void ___user *parent_tid, void __user *child_tid, struct pt_regs *regs
%define SYS_EXIT       60   ;int status
%define SYS_EXIT_GROUP 231  ;int status
%define SYS_NANOSLEEP 35    ;const struct timespec *req, struct timespec *rem
%define SYS_RT_SIGACTION 13 ;int sig,const struct sigaction __user * act,struct sigaction __user * oact,size_t sigsetsize
%define SYS_FUTEX        202;int *uaddr, int op, int val, const struct timespec *timeout, int *uaddr2, int val3
%define SYS_SOCKET       41 ;int domain, int type, int protocol
%define SYS_ACCEPT       43 ;int sockfd, struct sockaddr *addr, socklen_t *addrlen
%define SYS_SENDTO       44 ;int sockfd, const void *buf, size_t len, int flags, ...
%define SYS_RECVFROM	 45 ;int sockfd, void *buf, size_t len, int flags
%define SYS_BIND         49 ;int sockfd, const struct sockaddr *addr, socklen_t addrlen
%define SYS_LISTEN       50 ;int sockfd, int backlog
%define SYS_SELECT	     23 ;int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout
%define SYS_GETDENTS     78 ;unsigned int fd, struct linux_dirent *dirp, unsigned int count
%define SYS_OPEN		  2 ;const char *pathname, int flags, mode_t mode
%define SYS_CLOSE		  3 ;unsigned int fd