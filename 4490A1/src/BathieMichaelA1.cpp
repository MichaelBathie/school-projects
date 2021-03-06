/*
    Michael Bathie, 7835010
    COMP 4490 Assignment 1, Tumbling Dice
*/

#include "common.h"

#include <iostream>
#include <chrono>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_inverse.hpp>
#include <glm/gtc/type_ptr.hpp>

#define PI 3.14159265358979323846

const char *WINDOW_TITLE = "Tumbling Dice";
const double FRAME_RATE_MS = 1000.0 / 60.0;
const int FLOOR_HEIGHT = -2;
const float HYP_2 = (0.70710678118 / 2) + 0.1; //+ some leeway (hypotenuse length)
const GLfloat LO = 10;
const GLfloat HI = 20;
const GLfloat PI_2 = PI / 2;
const GLfloat PI_8 = PI / 8;

// Vertices of a unit cube centered at origin, sides aligned with axes
glm::vec4 diceVertices[8] = {
    glm::vec4(-0.5, -0.5, 0.5, 1.0),
    glm::vec4(-0.5, 0.5, 0.5, 1.0),
    glm::vec4(0.5, 0.5, 0.5, 1.0),
    glm::vec4(0.5, -0.5, 0.5, 1.0),
    glm::vec4(-0.5, -0.5, -0.5, 1.0),
    glm::vec4(-0.5, 0.5, -0.5, 1.0),
    glm::vec4(0.5, 0.5, -0.5, 1.0),
    glm::vec4(0.5, -0.5, -0.5, 1.0)};

GLuint diceIndices[] = {
    // each group of 3 is a triangle face
    1, 0, 3, 1, 3, 2,  //front face
    4, 5, 6, 4, 6, 7,  //back face
    2, 3, 7, 2, 7, 6,  //right face
    5, 4, 0, 5, 0, 1,  //left face
    3, 0, 4, 3, 4, 7,  //bottom face
    6, 5, 1, 6, 1, 2}; //top face

glm::vec4 pipVertices[9];

GLuint pipIndices[] = {
    0, 1, 2, 0, 2, 3,
    0, 3, 4, 0, 4, 5,
    0, 5, 6, 0, 6, 7,
    0, 7, 8, 0, 8, 1};

glm::vec4 tableVertices[4] = {
    glm::vec4(-4, -6, 0, 1.0),
    glm::vec4(-4, 6, 0, 1.0),
    glm::vec4(4, 6, 0, 1.0),
    glm::vec4(4, -6, 0, 1.0)};

GLuint tableIndices[] = {
    1, 0, 3, 1, 3, 2};

// Array of rotation angles (in degrees) for each coordinate axis
enum
{
    Xaxis = 0,
    Yaxis = 1,
    Zaxis = 2,
    Xaxis2 = 3,
    Yaxis2 = 4,
    Zaxis2 = 5,
    NumAxes = 6
};
int Axis = Yaxis;
GLfloat Theta[NumAxes] = {30.0, 0.0, 0.0, 30.0, 0.0, 0.0};
GLfloat xAngle;
GLfloat yAngle;
GLfloat zAngle;
GLfloat xAngle2;
GLfloat yAngle2;
GLfloat zAngle2;

// shader program variables (for switching between)
GLuint ProgramC;
GLuint ProgramP;
GLuint ProgramT;

// Model-view and projection matrices uniform location
GLuint ModelViewC, ProjectionC, ModelViewP, ProjectionP, ModelViewT, ProjectionT;
GLuint TimeC;
GLuint pipColour, tableColour, cubeColour;
GLuint windowSize, ScanLineC, ShadingSimulationC;

bool scanLine = true;
bool shadingSimulation = true;

bool movement = true;
bool cubeRotation = true;

//----------------------------------------------------------------------------

// need global access to VAOs
GLuint diceVertexArray;
GLuint pipVertexArray;
GLuint tableVertexArray;
GLuint vertexBufferID;
GLuint indexBufferID;

GLfloat dieZPosition = 5;
GLfloat dieYPosition = 1;

GLfloat cameraAngle = 0;
bool rotating = false;

void pipSetUp()
{
    pipVertices[0] = glm::vec4(0, 0, 0, 1);
    float angle = PI / 4;
    float x;
    float y;
    float radius = 0.1;

    for (int i = 1; i < 9; i++)
    {
        x = radius * cos(i * angle);
        y = radius * sin(i * angle);

        pipVertices[i] = glm::vec4(x, y, 0, 1);
    }
}

// OpenGL initialization
void init()
{
    srand(time(0));
    /*Source for random float generation*/
    /*https://stackoverflow.com/questions/686353/random-float-number-generation*/
    xAngle = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    yAngle = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    zAngle = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    xAngle2 = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    yAngle2 = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    zAngle2 = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));

    pipSetUp();

    // Create a vertex array object
    glGenVertexArrays(1, &diceVertexArray);
    glGenVertexArrays(1, &pipVertexArray);
    glGenVertexArrays(1, &tableVertexArray);

    // Load shaders and use the resulting shader program
    ProgramC = InitShader("vshadera1cube.glsl", "fshadera1cube.glsl");
    glUseProgram(ProgramC);
    GLuint vPosition = glGetAttribLocation(ProgramC, "vPosition"); //connect vPosition in the shader, to the underlying buffers
    GLuint vNormal = glGetAttribLocation(ProgramC, "vNormal");

    // object #1
    glBindVertexArray(diceVertexArray);

    /*==================setup buffers==================*/
    // Create and initialize a buffer object
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(diceVertices) + sizeof(pipVertices) + sizeof(tableVertices), NULL, GL_STATIC_DRAW);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(diceVertices), diceVertices);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(diceVertices), sizeof(pipVertices), pipVertices);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(diceVertices) + sizeof(pipVertices), sizeof(tableVertices), tableVertices);
    // Another for the index buffer
    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(diceIndices) + sizeof(pipIndices) + sizeof(tableIndices), NULL, GL_STATIC_DRAW);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(diceIndices), diceIndices);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, sizeof(diceIndices), sizeof(pipIndices), pipIndices);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, sizeof(diceIndices) + sizeof(pipIndices), sizeof(tableIndices), tableIndices);
    /*==================setup buffers==================*/

    /*==================vertex data for dice vao==================*/
    glEnableVertexAttribArray(vPosition);
    glVertexAttribPointer(vPosition, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    /*==================vertex data for dice vao==================*/

    ModelViewC = glGetUniformLocation(ProgramC, "ModelView"); //shader vars for cube shader
    ProjectionC = glGetUniformLocation(ProgramC, "Projection");
    cubeColour = glGetUniformLocation(ProgramC, "colour");
    TimeC = glGetUniformLocation(ProgramC, "Time");
    windowSize = glGetUniformLocation(ProgramC, "WindowSize");
    ScanLineC = glGetUniformLocation(ProgramC, "ScanLine");
    ShadingSimulationC = glGetUniformLocation(ProgramC, "ShadingSimulation");

    //initialise pip shader
    ProgramP = InitShader("vshadera1pip.glsl", "fshadera1pip.glsl");
    glUseProgram(ProgramP);
    vPosition = glGetAttribLocation(ProgramP, "vPosition");

    /*==================vertex data for pip vao + buffer binding==================*/
    glBindVertexArray(pipVertexArray);
    glEnableVertexAttribArray(vPosition);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glVertexAttribPointer(vPosition, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(sizeof(diceVertices)));
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    /*==================vertex data for pip vao + buffer binding==================*/
    pipColour = glGetUniformLocation(ProgramP, "colour"); //shader vars for pip shader
    ModelViewP = glGetUniformLocation(ProgramP, "ModelView");
    ProjectionP = glGetUniformLocation(ProgramP, "Projection");

    //initialise table shader
    ProgramT = InitShader("vshadera1table.glsl", "fshadera1table.glsl");
    glUseProgram(ProgramT);
    vPosition = glGetAttribLocation(ProgramT, "vPosition");

    /*==================vertex data for table vao + buffer binding==================*/
    glBindVertexArray(tableVertexArray);
    glEnableVertexAttribArray(vPosition);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glVertexAttribPointer(vPosition, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(sizeof(diceVertices) + sizeof(pipVertices)));
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    /*==================vertex data for table vao + buffer binding==================*/
    tableColour = glGetUniformLocation(ProgramT, "colour"); //shader vars for table shader
    ModelViewT = glGetUniformLocation(ProgramT, "ModelView");
    ProjectionT = glGetUniformLocation(ProgramT, "Projection");

    // this is used with "flat" in the shaders to get the same solid
    // colour for each face of the cube
    glProvokingVertex(GL_FIRST_VERTEX_CONVENTION);

    glEnable(GL_DEPTH_TEST);
    glShadeModel(GL_FLAT);
    glClearColor(1.0, 1.0, 1.0, 1.0);
}

//----------------------------------------------------------------------------
void display(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //  Generate the model-view matrix
    const glm::vec3 viewerPosition(0, -0.5, 8);

    long long ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                       std::chrono::system_clock::now().time_since_epoch())
                       .count();

    glm::mat4 trans, rot, rot2, cameraTilt, cameraRotate, view, modelView;
    rot = glm::rotate(rot, glm::radians(Theta[Xaxis]), glm::vec3(1, 0, 0));
    rot = glm::rotate(rot, glm::radians(Theta[Yaxis]), glm::vec3(0, 1, 0));
    rot = glm::rotate(rot, glm::radians(Theta[Zaxis]), glm::vec3(0, 0, 1));
    rot2 = glm::rotate(rot2, glm::radians(Theta[Xaxis2]), glm::vec3(1, 0, 0));
    rot2 = glm::rotate(rot2, glm::radians(Theta[Yaxis2]), glm::vec3(0, 1, 0));
    rot2 = glm::rotate(rot2, glm::radians(Theta[Zaxis2]), glm::vec3(0, 0, 1));
    cameraTilt = glm::rotate(glm::mat4(), PI_8, glm::vec3(1, 0, 0));
    cameraRotate = glm::rotate(glm::mat4(), glm::radians(cameraAngle), glm::vec3(0, 1, 0));

    if (rotating)
    { //if we're in rotate mode then keep adding to the angle
        if (cameraAngle >= 360)
        {
            cameraAngle = 0;
        }

        cameraAngle += 1;
    }

    view = glm::translate(glm::mat4(), -viewerPosition) * cameraTilt * cameraRotate;

    /*===================================TABLE===================================*/

    glUseProgram(ProgramT);

    glm::vec3 tColour(0.5, 0.3, 0.01);
    glUniform3fv(tableColour, 1, glm::value_ptr(tColour));

    glBindVertexArray(tableVertexArray);
    modelView = view * glm::translate(glm::mat4(), glm::vec3(0, FLOOR_HEIGHT, 0));
    modelView = modelView * glm::rotate(glm::mat4(), PI_2, glm::vec3(1, 0, 0));
    modelView = modelView * glm::scale(glm::mat4(), glm::vec3(0.5, 0.5, 0.5));
    glUniformMatrix4fv(ModelViewT, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(tableIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices) + sizeof(pipIndices)));

    /*===================================TABLE===================================*/
    /*===================================DIE 1===================================*/
    /*===================================BEWARE!!! MANY MODELVIEW MATRICES BEING SETUP BELOW!!!===================================*/

    // Drawing 1 die
    glUseProgram(ProgramC);
    glBindVertexArray(diceVertexArray);
    glm::vec3 cColour(1, 0, 0);
    glUniform3fv(cubeColour, 1, glm::value_ptr(cColour));

    glUniform1f(TimeC, (ms % 1000000) / 1000.0);
    glUniform1f(windowSize, 512.f);
    glUniform1i(ScanLineC, scanLine);
    glUniform1i(ShadingSimulationC, shadingSimulation);

    modelView = view * glm::translate(glm::mat4(), glm::vec3(0.75, dieYPosition, dieZPosition));
    modelView *= rot;
    modelView = modelView * glm::scale(glm::mat4(), glm::vec3(0.5, 0.5, 0.5));
    glUniformMatrix4fv(ModelViewC, 1, GL_FALSE, glm::value_ptr(modelView));

    //drawing each cube face and assigning colours
    glDrawElements(GL_TRIANGLES, (sizeof(diceIndices) / sizeof(GLuint) / 3), GL_UNSIGNED_INT, 0);
    cColour = glm::vec3(0, 1, 0);
    glUniform3fv(cubeColour, 1, glm::value_ptr(cColour));
    glDrawElements(GL_TRIANGLES, (sizeof(diceIndices) / sizeof(GLuint) / 3), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices) / 3));
    cColour = glm::vec3(0, 0, 1);
    glUniform3fv(cubeColour, 1, glm::value_ptr(cColour));
    glDrawElements(GL_TRIANGLES, (sizeof(diceIndices) / sizeof(GLuint) / 3), GL_UNSIGNED_INT, (void *)((sizeof(diceIndices) * 2) / 3));

    glUseProgram(ProgramP);

    glm::vec3 pColour(0.0, 0.0, 0.0);
    glUniform3fv(pipColour, 1, glm::value_ptr(pColour));

    glBindVertexArray(pipVertexArray);
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, 0.5001)); //5
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, -1.0002)); //2
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0.5001)); //4
    modelView = modelView * glm::rotate(glm::mat4(), PI_2, glm::vec3(0, 1, 0));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, -0.5001));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, 1.0002)); //3
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, -0.5001));

    modelView = modelView * glm::rotate(glm::mat4(), PI_2, glm::vec3(1, 0, 0)); //6
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0.5001));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, -1.0002)); //1
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, 0.5001));

    /*===================================DIE 1===================================*/
    /*===================================DIE 2===================================*/

    glUseProgram(ProgramC);
    glBindVertexArray(diceVertexArray);
    modelView = view * glm::translate(glm::mat4(), glm::vec3(-0.75, dieYPosition, dieZPosition));
    modelView *= rot2;
    modelView = modelView * glm::scale(glm::mat4(), glm::vec3(0.5, 0.5, 0.5));
    glUniformMatrix4fv(ModelViewC, 1, GL_FALSE, glm::value_ptr(modelView));

    //drawing each cube face and assigning colours
    cColour = glm::vec3(1, 0, 0);
    glUniform3fv(cubeColour, 1, glm::value_ptr(cColour));
    glDrawElements(GL_TRIANGLES, (sizeof(diceIndices) / sizeof(GLuint) / 3), GL_UNSIGNED_INT, 0);
    cColour = glm::vec3(0, 1, 0);
    glUniform3fv(cubeColour, 1, glm::value_ptr(cColour));
    glDrawElements(GL_TRIANGLES, (sizeof(diceIndices) / sizeof(GLuint) / 3), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices) / 3));
    cColour = glm::vec3(0, 0, 1);
    glUniform3fv(cubeColour, 1, glm::value_ptr(cColour));
    glDrawElements(GL_TRIANGLES, (sizeof(diceIndices) / sizeof(GLuint) / 3), GL_UNSIGNED_INT, (void *)((sizeof(diceIndices) * 2) / 3));

    glUseProgram(ProgramP);

    glBindVertexArray(pipVertexArray);
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, 0.5001)); //5
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, -1.0002)); //2
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0.5001)); //4
    modelView = modelView * glm::rotate(glm::mat4(), PI_2, glm::vec3(0, 1, 0));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, -0.5001));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, 1.0002)); //3
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, -0.5001));

    modelView = modelView * glm::rotate(glm::mat4(), PI_2, glm::vec3(1, 0, 0)); //6
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0.5001));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, -0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, 0, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0.25, -0.25, 0));
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(-0.25, 0.25, 0));

    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, -1.0002)); //1
    glUniformMatrix4fv(ModelViewP, 1, GL_FALSE, glm::value_ptr(modelView));
    glDrawElements(GL_TRIANGLES, sizeof(pipIndices) / sizeof(GLuint), GL_UNSIGNED_INT, (void *)(sizeof(diceIndices)));
    modelView = modelView * glm::translate(glm::mat4(), glm::vec3(0, 0, 0.5001));
    /*===================================DIE 2===================================*/

    glutSwapBuffers();
}

//When you press space this gets called
//Reset all the changing values to their original value (other than the camera rotation angle)
void resetObjects()
{
    xAngle = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    yAngle = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    zAngle = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    xAngle2 = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    yAngle2 = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));
    zAngle2 = LO + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / (HI - LO)));

    dieZPosition = 5;
    dieYPosition = 1;

    Theta[Xaxis] = 30.0;
    Theta[Yaxis] = 0.0;
    Theta[Zaxis] = 0.0;

    Theta[Xaxis2] = 30.0;
    Theta[Yaxis2] = 0.0;
    Theta[Zaxis2] = 0.0;
}

//----------------------------------------------------------------------------
//switch rotation state on mouse left click
void mouse(int button, int state, int x, int y)
{
    if (state == GLUT_DOWN)
    {
        switch (button)
        {
        case GLUT_LEFT_BUTTON:
            rotating = !rotating;
            break;
        }
    }
}

//----------------------------------------------------------------------------

void update(void)
{
    if (movement)
    {
        dieZPosition -= 0.1;
        if (dieYPosition > (FLOOR_HEIGHT + HYP_2))
        { //our hypotenuse length /2
            dieYPosition -= 0.1;
        }
    }

    if (cubeRotation)
    {
        Theta[Xaxis] += xAngle;
        Theta[Yaxis] += yAngle;
        Theta[Zaxis] += zAngle;

        Theta[Xaxis2] += xAngle2;
        Theta[Yaxis2] += yAngle2;
        Theta[Zaxis2] += zAngle2;

        if (Theta[Xaxis] > 360.0)
        {
            Theta[Xaxis] -= 360.0;
        }
        if (Theta[Yaxis] > 360.0)
        {
            Theta[Yaxis] -= 360.0;
        }
        if (Theta[Zaxis] > 360.0)
        {
            Theta[Zaxis] -= 360.0;
        }
        if (Theta[Xaxis2] > 360.0)
        {
            Theta[Xaxis2] -= 360.0;
        }
        if (Theta[Yaxis2] > 360.0)
        {
            Theta[Yaxis2] -= 360.0;
        }
        if (Theta[Zaxis2] > 360.0)
        {
            Theta[Zaxis2] -= 360.0;
        }
    }
}

//----------------------------------------------------------------------------

void keyboard(unsigned char key, int x, int y)
{
    switch (key)
    {
    case 033: // Escape Key
        exit(EXIT_SUCCESS);
        break;
    case 'q':
        exit(EXIT_SUCCESS);
        break;
    case 'Q':
        exit(EXIT_SUCCESS);
        break;
    case 32:
        resetObjects();
        break;
    case 'r':
        cubeRotation = !cubeRotation;
        break;
    case 'R':
        cubeRotation = !cubeRotation;
        break;
    case 'm':
        movement = !movement;
        break;
    case 'M':
        movement = !movement;
        break;
    case 'l':
        scanLine = !scanLine;
        break;
    case 'L':
        scanLine = !scanLine;
        break;
    case 's':
        shadingSimulation = !shadingSimulation;
        break;
    case 'S':
        shadingSimulation = !shadingSimulation;
        break;
    }
}
//----------------------------------------------------------------------------

void reshape(int width, int height)
{
    glViewport(0, 0, width, height);

    GLfloat aspect = GLfloat(width) / height;
    glm::mat4 projection = glm::perspective(glm::radians(45.0f), aspect, 0.5f, 15.0f);

    glUseProgram(ProgramC);
    glUniformMatrix4fv(ProjectionC, 1, GL_FALSE, glm::value_ptr(projection));
    glUseProgram(ProgramP);
    glUniformMatrix4fv(ProjectionP, 1, GL_FALSE, glm::value_ptr(projection));
    glUseProgram(ProgramT);
    glUniformMatrix4fv(ProjectionT, 1, GL_FALSE, glm::value_ptr(projection));
}
