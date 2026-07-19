#include "OS.h"
#include <stdexcept>
#include <vector>
#include <string>
#include <iostream>

#ifdef _WIN32
#include <windows.h>

// Convert UTF-8 std::string to std::wstring
static std::wstring to_wstring(const std::string& str) {
    if (str.empty()) return L"";
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], static_cast<int>(str.size()), nullptr, 0);
    std::wstring wstrTo(size_needed, 0);
    MultiByteToWideChar(CP_UTF8, 0, &str[0], static_cast<int>(str.size()), &wstrTo[0], size_needed);
    return wstrTo;
}

// Convert std::wstring to UTF-8 std::string
static std::string to_string(const std::wstring& wstr) {
    if (wstr.empty()) return "";
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], static_cast<int>(wstr.size()), nullptr, 0, nullptr, nullptr);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], static_cast<int>(wstr.size()), &strTo[0], size_needed, nullptr, nullptr);
    return strTo;
}

// Escapes an argument for a Windows command line (quoting if spaces/special chars present)
static std::wstring escape_argument(const std::wstring& arg) {
    if (arg.empty()) {
        return L"\"\"";
    }
    bool need_quotes = false;
    for (wchar_t c : arg) {
        if (c == L' ' || c == L'\t' || c == L'\n' || c == L'\v' || c == L'\"') {
            need_quotes = true;
            break;
        }
    }
    if (!need_quotes) {
        return arg;
    }

    std::wstring escaped = L"\"";
    for (size_t i = 0; i < arg.size(); ++i) {
        size_t backslashes = 0;
        while (i < arg.size() && arg[i] == L'\\') {
            backslashes++;
            i++;
        }

        if (i == arg.size()) {
            escaped.append(backslashes * 2, L'\\');
        } else if (arg[i] == L'\"') {
            escaped.append(backslashes * 2 + 1, L'\\');
            escaped.push_back(L'\"');
        } else {
            escaped.append(backslashes, L'\\');
            escaped.push_back(arg[i]);
        }
    }
    escaped.push_back(L'\"');
    return escaped;
}

int execute_command(const std::vector<std::string>& args) {
    // Construct command line starting with "git"
    std::wstring cmd = L"git";
    for (const auto& arg : args) {
        cmd += L" " + escape_argument(to_wstring(arg));
    }

    // Set up startup info to inherit standard I/O handles
    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    // Convert cmd string to a modifiable buffer required by CreateProcessW
    std::vector<wchar_t> cmd_buffer(cmd.begin(), cmd.end());
    cmd_buffer.push_back(L'\0');

    // Launch the child process, inheriting standard input/output/error
    BOOL success = CreateProcessW(
        nullptr,            // Application name
        cmd_buffer.data(),  // Command line
        nullptr,            // Process handle attributes
        nullptr,            // Thread handle attributes
        TRUE,               // Inherit handles
        0,                  // Creation flags
        nullptr,            // Environment block
        nullptr,            // Current working directory
        &si,                // Startup info
        &pi                 // Process information
    );

    if (!success) {
        DWORD err = GetLastError();
        LPWSTR messageBuffer = nullptr;
        size_t size = FormatMessageW(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
            nullptr, err, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), reinterpret_cast<LPWSTR>(&messageBuffer), 0, nullptr);
        
        std::string err_msg = "Failed to launch git process (Error code " + std::to_string(err) + ")";
        if (size > 0 && messageBuffer != nullptr) {
            std::wstring wmsg(messageBuffer);
            LocalFree(messageBuffer);
            err_msg += ": " + to_string(wmsg);
        }
        throw std::runtime_error(err_msg);
    }

    // Wait until git completes execution
    WaitForSingleObject(pi.hProcess, INFINITE);

    DWORD exit_code = 0;
    if (!GetExitCodeProcess(pi.hProcess, &exit_code)) {
        DWORD err = GetLastError();
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        throw std::runtime_error("Failed to get git process exit code (Error code " + std::to_string(err) + ")");
    }

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    return static_cast<int>(exit_code);
}
#else
#include <unistd.h>
#include <sys/wait.h>
#include <cstring>
#include <cerrno>

int execute_command(const std::vector<std::string>& args) {
    std::vector<char*> argv;
    std::string cmd = "git";
    argv.push_back(const_cast<char*>(cmd.c_str()));
    for (const auto& arg : args) {
        argv.push_back(const_cast<char*>(arg.c_str()));
    }
    argv.push_back(nullptr);

    pid_t pid = fork();
    if (pid == -1) {
        throw std::runtime_error(std::string("fork() failed: ") + std::strerror(errno));
    }

    if (pid == 0) {
        execvp("git", argv.data());
        std::cerr << "execvp() failed: " << std::strerror(errno) << "\n";
        _exit(127);
    } else {
        int status;
        if (waitpid(pid, &status, 0) == -1) {
            throw std::runtime_error(std::string("waitpid() failed: ") + std::strerror(errno));
        }
        if (WIFEXITED(status)) {
            return WEXITSTATUS(status);
        } else if (WIFSIGNALED(status)) {
            return 128 + WTERMSIG(status);
        }
        return 1;
    }
}
#endif
