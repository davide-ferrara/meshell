#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <linux/limits.h>
#include <stdarg.h>


#define RED   "\x1B[31m"
#define GRN   "\x1B[32m"
#define YEL   "\x1B[33m"
#define BLU   "\x1B[34m"
#define MAG   "\x1B[35m"
#define CYN   "\x1B[36m"
#define WHT   "\x1B[37m"
#define RESET "\x1B[0m"
#define BOLD "\033[1m"

#define log_info(...) tracelog(LOG_INFO, __VA_ARGS__)
#define log_err(...) tracelog(LOG_ERROR, __VA_ARGS__)
#define log_warn(...) tracelog(LOG_WARNING, __VA_ARGS__)
#define log_debug(...) tracelog(LOG_DEBUG, __VA_ARGS__)

#define MAX_ARGS 64
#define LOGIN_NAME getlogin()
#define OS_NAME get_os_name()


typedef enum {
  LOG_INFO,
  LOG_ERROR,
  LOG_WARNING,
  LOG_DEBUG,
} loglevel;


bool gen_prompt(char* prompt);
void str_to_lowercase(char* str);
char* get_os_name(void);
void parse_input(char* input, char* args[]);
void tracelog(loglevel level, char* fmt, ...);


int main()
{
  const char *bold = "\033[1m";

  char cwd[PATH_MAX]; 
  char* prompt = (char*)malloc((PATH_MAX + 1024) * sizeof(char));
  char* home_path = (char*)malloc(1024 * sizeof(char));

  strcpy(home_path, "/home/");
  strcat(home_path, LOGIN_NAME);

  if(chdir(home_path) != 0) {
    log_err("could not change dir to home");
    free(prompt);
    free(home_path);
    exit(-1);
  };

  if(!gen_prompt(prompt))
    log_err("could not generate prompt");

  // Configure readline to auto-complete paths when the tab key is hit.
  rl_bind_key('\t', rl_complete);

  // Enable history
  using_history();

  while (1) {
    pid_t pid;

    // Display prompt and read input
    char* input = readline(prompt);

    // Check for EOF.
    if (!input)
      break;

    if(strcmp(input, "exit") == 0)
      break;

    if(input) {
      char* args[MAX_ARGS];
      parse_input(input, args);

      char *cmd = args[0];
      // CD COMMAND
      if(strcmp(cmd, "cd") == 0) {
        char *path = args[1];
        if(path == NULL)
          chdir("/");

        if(!chdir(path) == 0 && path != NULL)
          log_err("could not find specified path!");

        if(!gen_prompt(prompt))
          log_err("could not generate prompt");

      } else {

        pid = fork();

        if(pid == 0) {

          execvp(cmd, args);
          log_err("command not found: %s", cmd);
        } else if (pid > 0) {
          wait(NULL);
        } else {
          log_err("Could not fork Mishell process!");
        }
      }

    }

    // Add input to readline history.
    add_history(input);

    // Free buffer that was allocated by readline
    free(input);
  }
  exit(0);
}


void str_to_lowercase(char* str) {
  while(*str) {
    *str = tolower((unsigned char)*str);
    str++;
  }
}


char* get_os_name(void) {
  size_t n = 256;
  char* os_name = (char*)malloc(n*sizeof(char));
  FILE* file = fopen("/etc/os-release", "r");

  if(file == NULL) {
    fprintf(stderr, "Could not find os release!\n");
    os_name = "unknown";
    return os_name;
  }

  char* line = (char*)malloc(n*sizeof(char));
  while(fgets(line, n, file)) {
    if(strncmp(line, "NAME=", 5) == 0) {
      char* sub_str = strtok(line, "\"");
      sub_str = strtok(NULL, " ");
      strcpy(os_name, sub_str);
      break;
    }
  }

  str_to_lowercase(os_name);
  free(line);
  fclose(file);

  return os_name;
}

void parse_input(char* input, char* args[]) {
  size_t i = 1;
  char* token = strtok(input, " ");

  if(token == NULL) {
    log_err("Token is NULL!");
    return;
  }

  args[0] = token;
  while(token != NULL) {
    token = strtok(NULL, " ");
    args[i] = token;
    ++i;
  }

}

bool gen_prompt(char* prompt) {
  char cwd[PATH_MAX]; 

  if(getcwd(cwd, sizeof(cwd)) == NULL) {
    log_err("Could not get cwd!");
    return false;
  }
  sprintf(prompt, "%s%s%s@%s%s:%s%s%s%s> ", BOLD, CYN, LOGIN_NAME, OS_NAME, RESET, BOLD, CYN, cwd, RESET);
  return true;
}

void tracelog(loglevel level, char* fmt, ...) {
  va_list args;
  va_start(args, fmt);

  char buf[1024];
  switch (level) {
    case LOG_INFO:
      snprintf(buf, sizeof(buf), "[INFO]: %s%s\n", fmt, RESET);
      vfprintf(stderr, buf, args);
      break;
    case LOG_WARNING:
      snprintf(buf, sizeof(buf), "%sMeshell: %s%s\n", YEL, fmt, RESET);
      vfprintf(stderr, buf, args);
      break;
    case LOG_ERROR:
      snprintf(buf, sizeof(buf), "%sMeshell: %s%s\n", RED, fmt, RESET);
      vfprintf(stderr, buf, args);
      break;
    case LOG_DEBUG:
      snprintf(buf, sizeof(buf), "%s[DEBUG]: %s%s\n", GRN, fmt, RESET);
      vfprintf(stderr, buf, args);
      break;

  }
  va_end(args);
}


