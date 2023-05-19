/*******************************************************************************************
 *
 *   Ijo - Playground v0.1.0 - Playground to test the ijo programming language
 *
 *   LICENSE: Propietary License
 *
 *   Copyright (c) 2022 JRacaud. All Rights Reserved.
 *
 *   Unauthorized copying of this file, via any medium is strictly prohibited
 *   This project is proprietary and confidential unless the owner allows
 *   usage in any other form by expresely written permission.
 *
 **********************************************************************************************/
#include <cstdio>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <string>

#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <stdio.h>
#define GL_SILENCE_DEPRECATION
#if defined(IMGUI_IMPL_OPENGL_ES2)
#include <GLES2/gl2.h>
#endif
#include <GLFW/glfw3.h> // Will drag system OpenGL headers

#include "TextEditor.h"

#include "gc/ijoNaiveGC.h"
#include "ijoChunk.h"
#include "ijoCommon.h"
#include "ijoCompiler.h"
#include "ijoDebug.h"
#include "ijoLog.h"
#include "ijoVM.h"

#if defined(IMGUI_IMPL_OPENGL_ES2)
const char *glsl_version = "#version 100";
#elif defined(__APPLE__)
const char *glsl_version = "#version 150";
#else
const char *glsl_version = "#version 130";
#endif

//----------------------------------------------------------------------------------
// Controls Functions Declaration
//----------------------------------------------------------------------------------
static InterpretResult BuildButton(ijoVM *vm);
static InterpretResult RunButton(ijoVM *vm);

std::string SourceCodeMultiTextBoxText = "";
std::string ByteCodeTextBoxText = "";
std::string ResultTextBoxText = "";

static void glfw_error_callback(int error, const char *description)
{
  fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

GLFWwindow *GLFWInit()
{
  glfwSetErrorCallback(glfw_error_callback);
  if (!glfwInit())
    return nullptr;

    // Decide GL+GLSL versions
#if defined(IMGUI_IMPL_OPENGL_ES2)
  // GL ES 2.0 + GLSL 100
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
#elif defined(__APPLE__)
  // GL 3.2 + GLSL 150
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); // 3.2+ only
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);           // Required on Mac
#else
  // GL 3.0 + GLSL 130
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  // glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);  // 3.2+ only
  // glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);            // 3.0+ only
#endif

  // Create window with graphics context
  GLFWwindow *window = glfwCreateWindow(1280, 720, "ijo - Playground", nullptr, nullptr);
  if (window == nullptr)
    return nullptr;
  glfwMakeContextCurrent(window);
  glfwSwapInterval(1); // Enable vsync

  return window;
}

void ImGuiInit(GLFWwindow *window)
{
  // Setup Dear ImGui context
  IMGUI_CHECKVERSION();
  ImGui::CreateContext();
  ImGuiIO &io = ImGui::GetIO();
  (void)io;
  io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard | ImGuiConfigFlags_DockingEnable; // Enable Keyboard Controls

  // Setup Dear ImGui style
  ImGui::StyleColorsDark();
  // ImGui::StyleColorsLight();

  // Setup Platform/Renderer backends
  ImGui_ImplGlfw_InitForOpenGL(window, true);
  ImGui_ImplOpenGL3_Init(glsl_version);
}

bool SourceCodeEditor(TextEditor &editor)
{
  auto cpos = editor.GetCursorPosition();

  ImGui::Begin("ijo - Source Code", nullptr, ImGuiWindowFlags_MenuBar);
  if (ImGui::BeginMenuBar())
  {
    if (ImGui::BeginMenu("File"))
    {
      if (ImGui::MenuItem("Save", "Ctrl-S", nullptr))
      {
        auto textToSave = editor.GetText();
        /// save text....
      }
      if (ImGui::MenuItem("Quit", "Alt-F4"))
        return true;
      ImGui::EndMenu();
    }
    if (ImGui::BeginMenu("Edit"))
    {
      bool ro = editor.IsReadOnly();
      if (ImGui::MenuItem("Read-only mode", nullptr, &ro))
        editor.SetReadOnly(ro);
      ImGui::Separator();

      if (ImGui::MenuItem("Undo", "ALT-Backspace", nullptr, !ro && editor.CanUndo()))
        editor.Undo();
      if (ImGui::MenuItem("Redo", "Ctrl-Y", nullptr, !ro && editor.CanRedo()))
        editor.Redo();

      ImGui::Separator();

      if (ImGui::MenuItem("Copy", "Ctrl-C", nullptr, editor.HasSelection()))
        editor.Copy();
      if (ImGui::MenuItem("Cut", "Ctrl-X", nullptr, !ro && editor.HasSelection()))
        editor.Cut();
      if (ImGui::MenuItem("Delete", "Del", nullptr, !ro && editor.HasSelection()))
        editor.Delete();
      if (ImGui::MenuItem("Paste", "Ctrl-V", nullptr, !ro && ImGui::GetClipboardText() != nullptr))
        editor.Paste();

      ImGui::Separator();

      if (ImGui::MenuItem("Select all", nullptr, nullptr))
        editor.SetSelection(TextEditor::Coordinates(), TextEditor::Coordinates(editor.GetTotalLines(), 0));

      ImGui::EndMenu();
    }

    if (ImGui::BeginMenu("View"))
    {
      if (ImGui::MenuItem("Dark palette"))
        editor.SetPalette(TextEditor::GetDarkPalette());
      if (ImGui::MenuItem("Light palette"))
        editor.SetPalette(TextEditor::GetLightPalette());
      if (ImGui::MenuItem("Retro blue palette"))
        editor.SetPalette(TextEditor::GetRetroBluePalette());
      ImGui::EndMenu();
    }
    ImGui::EndMenuBar();
  }

  ImGui::Text("%6d/%-6d %6d lines  | %s | %s | %s | %s", cpos.mLine + 1, cpos.mColumn + 1, editor.GetTotalLines(),
              editor.IsOverwrite() ? "Ovr" : "Ins",
              editor.CanUndo() ? "*" : " ",
              editor.GetLanguageDefinition().mName.c_str(), "playground.ijo");

  editor.Render("TextEditor");

  ImGui::End();

  return false;
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
int main()
{
  auto window = GLFWInit();
  if (!window)
  {
    return 1;
  }

  ImGuiInit(window);

  ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

  const char *sourceCodeLabelText = "Source Code";
  const char *ByteCodeLabelText = "ByteCode";
  const char *BuildButtonText = "Generate ByteCode";
  const char *RunButtonText = "Run";

  bool SourceCodeMultiTextBoxEditMode = false;

  TextEditor editor;
  auto lang = TextEditor::LanguageDefinition::ijo();
  editor.SetLanguageDefinition(lang);
  editor.SetText(SourceCodeMultiTextBoxText);

  ijoVM vm;
  ijoVMInit(&vm);

  Chunk chunk;
  ChunkNew(&chunk);
  vm.chunk = &chunk;

  gc = NaiveGCNodeCreate(NULL);

  while (!glfwWindowShouldClose(window))
  {
    glfwPollEvents();

    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGui::SetNextWindowSize(ImGui::GetIO().DisplaySize);
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::Begin("Dock", nullptr, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoResize);
    ImGui::End();

    // Returns true when the quit menu item is clicked
    if (SourceCodeEditor(editor))
    {
      break;
    }

    ImGui::Begin("ByteCode", nullptr, ImGuiWindowFlags_NoCollapse);
    ImGui::Text(ByteCodeTextBoxText.c_str());
    ImGui::End();

    ImGui::Begin("Result", nullptr, ImGuiWindowFlags_NoCollapse);
    ImGui::Text(ResultTextBoxText.c_str());
    ImGui::End();

    ImGui::Begin("Build & Run", nullptr, ImGuiWindowFlags_NoCollapse);
    if (ImGui::Button("Generate ByteCode"))
    {
      BuildButton(&vm);
    }

    if (!ByteCodeTextBoxText.empty() && ImGui::Button("Run"))
    {
      RunButton(&vm);
    }
    ImGui::End();

    // Rendering
    ImGui::Render();
    int display_w, display_h;
    glfwGetFramebufferSize(window, &display_w, &display_h);
    glViewport(0, 0, display_w, display_h);
    glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
    glClear(GL_COLOR_BUFFER_BIT);
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

    glfwSwapBuffers(window);
  }

  // Cleanup
  ImGui_ImplOpenGL3_Shutdown();
  ImGui_ImplGlfw_Shutdown();
  ImGui::DestroyContext();

  glfwDestroyWindow(window);
  glfwTerminate();

  ChunkDelete(vm.chunk);
  NaiveGCClear(gc);
  ijoVMDeinit(&vm);

  return 0;
}

//------------------------------------------------------------------------------------
// Controls Functions Definitions (local)
//------------------------------------------------------------------------------------
static InterpretResult BuildButton(ijoVM *vm)
{
  ChunkDelete(vm->chunk);
  ChunkNew(vm->chunk);

  // This ensure a conform program.
  SourceCodeMultiTextBoxText.append("\n");

  if (!Compile(SourceCodeMultiTextBoxText.c_str(), vm->chunk, &vm->interned, COMPILE_REPL))
  {
    ChunkDelete(vm->chunk);
    return INTERPRET_COMPILE_ERROR;
  }

  FILE *tmpfile = std::tmpfile();
  DisassembleChunk(vm->chunk, "Playground", tmpfile);

  // rewind the file pointer so that we can read it
  std::rewind(tmpfile);

  // read the file contents into a string
  std::ifstream filestream(tmpfile);
  std::string byteCodeStr((std::istreambuf_iterator<char>(filestream)), std::istreambuf_iterator<char>());
  ByteCodeTextBoxText = byteCodeStr;

  vm->ip = vm->chunk->code;

  return INTERPRET_OK;
}

#include "ijoLog.h"

static InterpretResult RunButton(ijoVM *vm)
{
  // create a temporary file
  FILE *tmpfile = std::tmpfile();

  InterpretResult result = ijoVMRun(vm, COMPILE_FILE, tmpfile);

  // rewind the file pointer so that we can read it
  std::rewind(tmpfile);

  // read the file contents into a string
  std::ifstream filestream(tmpfile);
  std::string programOutput((std::istreambuf_iterator<char>(filestream)), std::istreambuf_iterator<char>());

  ResultTextBoxText = programOutput;

  // close and delete the temporary file
  std::fclose(tmpfile);

  // return result;
  return INTERPRET_OK;
}