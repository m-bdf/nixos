#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <sys/stat.h>
#include <glob.h>
#include <fcntl.h>
#include <unistd.h>

int isatty(int fd) {
  if (__isatty(fd)) return 1;
  if (fd != 1) return 0;

  const char *pager = getenv("PAGER");
  if (!pager || !pager[0]) return 0;
  char comm[strlen(pager) + 1];

  static char cmdline[PATH_MAX],
    path[PATH_MAX] = "/dev/stdout";
  const char *cmd = cmdline;

  static struct stat statself, statbuf;
  if (stat(path, &statself) < 0) return 0;

  static glob_t globbuf;
  const int flags = GLOB_NOSORT | GLOB_ONLYDIR;
  glob("/proc/[0-9]*", flags, NULL, &globbuf);

  for (int i = globbuf.gl_pathc; i--; ) {
    strcpy(path, globbuf.gl_pathv[i]);
    int len = strlen(path);

    strcpy(path + len, "/fd/0");
    if (stat(path, &statbuf) < 0 ||
      statbuf.st_ino != statself.st_ino) continue;

    globfree(&globbuf);

    strcpy(path + len, "/cmdline");
    if ((fd = open(path, O_RDONLY)) < 0) return 0;

    if (read(fd, cmdline, sizeof(cmdline)) < 0 ||
      close(fd) < 0) return 0;

    if (cmdline[0] == '/')
      cmd = strrchr(cmdline, '/') + 1;
    if (!strcmp(cmd, pager)) return 1;

    strcpy(path + len, "/comm");
    if ((fd = open(path, O_RDONLY)) < 0) return 0;

    if ((len = read(fd, comm, sizeof(comm))) < 0 ||
      close(fd) < 0) return 0;

    return comm[len - 1] == '\n' &&
      !strncmp(comm, pager, len - 1);
  }

  globfree(&globbuf);
  return 0;
}
