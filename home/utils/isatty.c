#include <stdlib.h>
#include <limits.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <glob.h>

static int ispager(int len;
  char procpath[len], int len)
{
  const char *pager = getenv("PAGER");
  if (!pager || !pager[0]) return 0;

  static char buf[PATH_MAX], *cmd = buf;
  int fd;

  strcpy(procpath + len, "/cmdline");
  if ((fd = open(procpath, O_RDONLY)) < 0 ||
    read(fd, buf, sizeof(buf)) < 0 ||
    close(fd) < 0) return 0;

  if (buf[0] == '/')
    cmd = strrchr(buf, '/') + 1;
  if (!strcmp(cmd, pager)) return 1;

  strcpy(procpath + len, "/comm");
  if ((fd = open(procpath, O_RDONLY)) < 0 ||
    (len = read(fd, buf, sizeof(buf))) < 0 ||
    close(fd) < 0) return 0;

  return buf[len - 1] == '\n' &&
    !strncmp(buf, pager, len - 1);
}

int isatty(int fd)
{
  if (__isatty(fd)) return 1;
  if (fd != 1) return 0;

  static struct stat statbuf;
  if (stat("/dev/stdout", &statbuf) < 0) return 0;
  ino_t ino = statbuf.st_ino;

  static glob_t globbuf;
  const int flags = GLOB_NOSORT | GLOB_ONLYDIR;
  glob("/proc/[0-9]*", flags, NULL, &globbuf);

  for (int i = globbuf.gl_pathc; i--; )
  {
    static char procpath[PATH_MAX];
    strcpy(procpath, globbuf.gl_pathv[i]);
    int len = strlen(procpath);

    strcpy(procpath + len, "/fd/0");
    if (stat(procpath, &statbuf) < 0 ||
      statbuf.st_ino != ino) continue;

    globfree(&globbuf);
    return ispager(procpath, len);
  }

  globfree(&globbuf);
  return 0;
}
