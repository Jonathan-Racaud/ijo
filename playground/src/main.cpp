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
#include "imgui_internal.h"
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
void Run();

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
  io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard | ImGuiConfigFlags_DockingEnable;

  // Setup Dear ImGui style
  ImGui::StyleColorsDark();
  // ImGui::StyleColorsLight();

  // Setup Platform/Renderer backends
  ImGui_ImplGlfw_InitForOpenGL(window, true);
  ImGui_ImplOpenGL3_Init(glsl_version);
}

void SourceCodeEditor(TextEditor &editor)
{
  auto cpos = editor.GetCursorPosition();

  ImGui::Begin("Source Code");

  ImGui::Text("%6d/%-6d %6d lines  | %s | %s | %s | %s", cpos.mLine + 1, cpos.mColumn + 1, editor.GetTotalLines(),
              editor.IsOverwrite() ? "Ovr" : "Ins",
              editor.CanUndo() ? "*" : " ",
              editor.GetLanguageDefinition().mName.c_str(), "playground.ijo");

  editor.Render("TextEditor");

  ImGui::End();
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

  while (!glfwWindowShouldClose(window))
  {
    glfwPollEvents();

    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    static ImGuiDockNodeFlags dockspace_flags = ImGuiDockNodeFlags_PassthruCentralNode;

    // We are using the ImGuiWindowFlags_NoDocking flag to make the parent window not dockable into,
    // because it would be confusing to have two docking targets within each others.
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoDocking;

    ImGuiViewport *viewport = ImGui::GetMainViewport();
    ImGui::SetNextWindowPos(viewport->Pos);
    ImGui::SetNextWindowSize(viewport->Size);

    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);

    window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoSavedSettings;
    window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus | ImGuiWindowFlags_MenuBar;

    // When using ImGuiDockNodeFlags_PassthruCentralNode, DockSpace() will render our background and handle the pass-thru hole, so we ask Begin() to not render a background.
    if (dockspace_flags & ImGuiDockNodeFlags_PassthruCentralNode)
      window_flags |= ImGuiWindowFlags_NoBackground;

    // Important: note that we proceed even if Begin() returns false (aka window is collapsed).
    // This is because we want to keep our DockSpace() active. If a DockSpace() is inactive,
    // all active windows docked into it will lose their parent and become undocked.
    // We cannot preserve the docking relationship between an active window and an inactive docking, otherwise
    // any change of dockspace/settings would lead to windows being stuck in limbo and never being visible.
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0.0f, 0.0f));
    ImGui::Begin("DockSpace", nullptr, window_flags);

    if (ImGui::BeginMenuBar())
    {
      if (ImGui::BeginMenu("File"))
      {
        if (ImGui::MenuItem("Save", "Ctrl-S", nullptr))
        {
          SourceCodeMultiTextBoxText = editor.GetText();
        }
        if (ImGui::MenuItem("Clear", "Ctrl-L"))
        {
          SourceCodeMultiTextBoxText.clear();
        }
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
      if (ImGui::MenuItem("Run"))
      {
        Run();
      }
      ImGui::EndMenuBar();
    }

    ImGui::PopStyleVar();
    ImGui::PopStyleVar(2);

    // DockSpace
    ImGuiIO &io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_DockingEnable)
    {
      ImGuiID dockspace_id = ImGui::GetID("DockSpace");
      ImGui::DockSpace(dockspace_id, ImVec2(0.0f, 0.0f), dockspace_flags);

      static auto first_time = true;
      if (first_time)
      {
        first_time = false;

        ImGui::DockBuilderRemoveNode(dockspace_id); // clear any previous layout
        ImGui::DockBuilderAddNode(dockspace_id, dockspace_flags | ImGuiDockNodeFlags_DockSpace);
        ImGui::DockBuilderSetNodeSize(dockspace_id, viewport->Size);

        // split the dockspace into 2 nodes -- DockBuilderSplitNode takes in the following args in the following order
        //   window ID to split, direction, fraction (between 0 and 1), the final two setting let's us choose which id we want (which ever one we DON'T set as NULL, will be returned by the function)
        //                                                              out_id_at_dir is the id of the node in the direction we specified earlier, out_id_at_opposite_dir is in the opposite direction
        auto dock_id_left = ImGui::DockBuilderSplitNode(dockspace_id, ImGuiDir_Left, 0.25f, nullptr, &dockspace_id);
        auto dock_id_center = ImGui::DockBuilderSplitNode(dockspace_id, ImGuiDir_Left, 0.3f, nullptr, &dockspace_id);

        // we now dock our windows into the docking node we made above
        ImGui::DockBuilderDockWindow("Source Code", dock_id_left);
        ImGui::DockBuilderDockWindow("ByteCode", dock_id_center);
        ImGui::DockBuilderDockWindow("Result", dockspace_id);
        ImGui::DockBuilderFinish(dockspace_id);
      }
    }

    ImGui::End();

    // Returns true when the quit menu item is clicked
    SourceCodeEditor(editor);

    ImGui::Begin("ByteCode", nullptr, ImGuiWindowFlags_NoCollapse);
    ImGui::Text(ByteCodeTextBoxText.c_str());
    ImGui::End();

    ImGui::Begin("Result", nullptr, ImGuiWindowFlags_NoCollapse);
    ImGui::Text(ResultTextBoxText.c_str());
    ImGui::End();

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

  return 0;
}

//------------------------------------------------------------------------------------
// Controls Functions Definitions (local)
//------------------------------------------------------------------------------------
void PrintByteCode(Chunk *chunk)
{
  FILE *tmpfile = std::tmpfile();
  DisassembleChunk(chunk, "Playground", tmpfile);

  // rewind the file pointer so that we can read it
  std::rewind(tmpfile);

  // read the file contents into a string
  std::ifstream filestream(tmpfile);
  std::string byteCodeStr((std::istreambuf_iterator<char>(filestream)), std::istreambuf_iterator<char>());
  ByteCodeTextBoxText = byteCodeStr;

  std::fclose(tmpfile);
}

void ResetTextBoxes()
{
  ByteCodeTextBoxText = "";
  ResultTextBoxText = "";
}

void Run()
{
  ResetTextBoxes();

  ijoVM vm;
  ijoVMInit(&vm);

  gc = NaiveGCNodeCreate(NULL);

  Chunk chunk;
  ChunkNew(&chunk);

  // This ensure a conform program.
  SourceCodeMultiTextBoxText.append("\n");

  if (!Compile(SourceCodeMultiTextBoxText.c_str(), &chunk, &vm.interned, COMPILE_FILE))
  {
    ChunkDelete(&chunk);
    ByteCodeTextBoxText = "[ERROR]\n";
    return;
  }

  PrintByteCode(&chunk);

  vm.chunk = &chunk;
  vm.ip = vm.chunk->code;

  FILE *tmpfile = std::tmpfile();

  if (ijoVMRun(&vm, COMPILE_FILE, tmpfile) != INTERPRET_OK)
  {
    ResultTextBoxText = "[ERROR]\n";
  }

  // rewind the file pointer so that we can read it
  std::rewind(tmpfile);

  // read the file contents into a string
  std::ifstream filestream(tmpfile);
  std::string programOutput((std::istreambuf_iterator<char>(filestream)), std::istreambuf_iterator<char>());

  ResultTextBoxText.append(programOutput);

  // close and delete the temporary file
  std::fclose(tmpfile);

  ChunkDelete(&chunk);

  NaiveGCClear(gc);
  ijoVMDeinit(&vm);
}