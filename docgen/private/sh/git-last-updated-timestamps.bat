@echo off
REM Wrapper to invoke PowerShell script for Bazel on Windows
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "%~dp0git-last-updated-timestamps.ps1" %*
