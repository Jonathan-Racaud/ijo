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
#include "raylib.h"

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

#include <cstdio>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <string>

#include "gc/ijoNaiveGC.h"
#include "ijoChunk.h"
#include "ijoCommon.h"
#include "ijoCompiler.h"
#include "ijoDebug.h"
#include "ijoLog.h"
#include "ijoVM.h"

//----------------------------------------------------------------------------------
// Controls Functions Declaration
//----------------------------------------------------------------------------------
static InterpretResult BuildButton(ijoVM *vm);
static InterpretResult RunButton(ijoVM *vm);

char SourceCodeMultiTextBoxText[1024] = "";
std::string ByteCodeTextBoxText = "";
std::string ResultTextBoxText = "";

bool GuiTextBoxMulti(Rectangle bounds, char *text, int bufferSize, bool editMode)
{
  bool pressed = false;

  GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT_VERTICAL, 1);
  GuiSetStyle(TEXTBOX, TEXT_MULTILINE, 1);

  // TODO: Implement methods to calculate cursor position properly
  pressed = GuiTextBox(bounds, text, bufferSize, editMode);

  GuiSetStyle(TEXTBOX, TEXT_MULTILINE, 0);
  GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT_VERTICAL, 0);

  return pressed;
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
int main()
{
  // VM Initialization
  //---------------------------------------------------------------------------------------
  ijoVM vm;
  ijoVMInit(&vm);

  Chunk chunk;
  vm.chunk = &chunk;

  gc = NaiveGCNodeCreate(NULL);

  // GUI Initialization
  //---------------------------------------------------------------------------------------
  int screenWidth = 900;
  int screenHeight = 550;

  InitWindow(screenWidth, screenHeight, "ijo - Playground");

  // ijo - Playground: controls initialization
  //----------------------------------------------------------------------------------
  const char *sourceCodeLabelText = "Source Code";
  const char *ByteCodeLabelText = "ByteCode";
  const char *BuildButtonText = "Generate ByteCode";
  const char *RunButtonText = "Run";

  Vector2 anchor = {24, 24};

  bool SourceCodeMultiTextBoxEditMode = false;
  //----------------------------------------------------------------------------------

  SetTargetFPS(60);
  //--------------------------------------------------------------------------------------

  // Main game loop
  while (!WindowShouldClose()) // Detect window close button or ESC key
  {
    // Update
    //----------------------------------------------------------------------------------
    // TODO: Implement required update logic
    //----------------------------------------------------------------------------------

    // Draw
    //----------------------------------------------------------------------------------
    BeginDrawing();

    ClearBackground(GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR)));

    // raygui: controls drawing
    //----------------------------------------------------------------------------------
    GuiLabel({anchor.x + 0, anchor.y + 0, 120, 24}, sourceCodeLabelText);
    if (GuiTextBoxMulti({24, 48, 312, 480}, SourceCodeMultiTextBoxText, 1024, SourceCodeMultiTextBoxEditMode))
    {
      SourceCodeMultiTextBoxEditMode = !SourceCodeMultiTextBoxEditMode;
    }

    GuiLabel({360, 24, 120, 24}, ByteCodeLabelText);
    GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT_VERTICAL, 1);
    GuiTextBox({360, 48, 288, 480}, (char *)ByteCodeTextBoxText.c_str(), 128, false);
    GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT_VERTICAL, 0);

    if (GuiButton({672, 48, 192, 24}, BuildButtonText))
    {
      switch (BuildButton(&vm))
      {
      case INTERPRET_OK:
        ResultTextBoxText = "Build OK";
        break;
      case INTERPRET_COMPILE_ERROR:
        ResultTextBoxText = "Build Error";
        break;
      }
    }

    if ((ByteCodeTextBoxText != "") && GuiButton({672, 80, 192, 24}, RunButtonText))
    {
      switch (RunButton(&vm))
      {
      case INTERPRET_OK:
        break;
      case INTERPRET_RUNTIME_ERROR:
        ResultTextBoxText = "Error running code";
        break;
      }
    }

    GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT_VERTICAL, 1);
    GuiTextBox({672, 112, 192, 416}, (char *)ResultTextBoxText.c_str(), 128, false);
    GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT_VERTICAL, 0);
    //----------------------------------------------------------------------------------

    EndDrawing();
    //----------------------------------------------------------------------------------
  }

  // De-Initialization
  //--------------------------------------------------------------------------------------
  CloseWindow(); // Close window and OpenGL context
  //--------------------------------------------------------------------------------------

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
  size_t len = strlen(SourceCodeMultiTextBoxText);
  if (len < 1024 && len > 0)
  {
    SourceCodeMultiTextBoxText[len] = '\n';
    SourceCodeMultiTextBoxText[len + 1] = '\0';
  }

  if (!Compile(SourceCodeMultiTextBoxText, vm->chunk, &vm->interned, COMPILE_REPL))
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