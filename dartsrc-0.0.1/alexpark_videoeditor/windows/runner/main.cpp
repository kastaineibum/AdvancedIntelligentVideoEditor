#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "run_loop.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command)
{
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent())
  {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  RunLoop run_loop;

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(&run_loop, project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1440, 900);
  if (!window.CreateAndShow(L"AdvancedIntelligence Video Editor (AVE)", origin, size))
  {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);
  //HWND is window handler
  HWND hwnd = window.GetHandle();

  auto windowHDC = GetDC(hwnd);
  int fullscreenWidth = GetDeviceCaps(windowHDC, DESKTOPHORZRES);
  int fullscreenHeight = GetDeviceCaps(windowHDC, DESKTOPVERTRES);
  int colourBits = GetDeviceCaps(windowHDC, BITSPIXEL);
  int refreshRate = GetDeviceCaps(windowHDC, VREFRESH);

  DEVMODE fullscreenSettings;
  bool isChangeSuccessful;

  EnumDisplaySettings(NULL, 0, &fullscreenSettings);
  fullscreenSettings.dmPelsWidth = fullscreenWidth;
  fullscreenSettings.dmPelsHeight = fullscreenHeight;
  fullscreenSettings.dmBitsPerPel = colourBits;
  fullscreenSettings.dmDisplayFrequency = refreshRate;
  fullscreenSettings.dmFields = DM_PELSWIDTH |
                                DM_PELSHEIGHT |
                                DM_BITSPERPEL |
                                DM_DISPLAYFREQUENCY;

  SetWindowLongPtr(hwnd, GWL_EXSTYLE, WS_EX_APPWINDOW | WS_EX_TOPMOST);
  SetWindowLongPtr(hwnd, GWL_STYLE, WS_POPUP | WS_VISIBLE);
  SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, fullscreenWidth, fullscreenHeight, SWP_SHOWWINDOW);
  isChangeSuccessful = ChangeDisplaySettings(&fullscreenSettings, CDS_FULLSCREEN) == DISP_CHANGE_SUCCESSFUL;
  ShowWindow(hwnd, SW_MAXIMIZE);
  run_loop.Run();

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
