-- Vertex

#version 430 core

layout(location = 0) in vec3 vertexPosition;

// Model-view-projection matrix
uniform mat4 mvpMatrix;

void main()
{
	gl_Position = mvpMatrix * vec4(vertexPosition, 1.0);
}


-- Fragment

#version 430 core

#include "PixelSyncHeader.glsl"

void main()
{
	int x = int(gl_FragCoord.x);
	int y = int(gl_FragCoord.y);
	numFragmentsBuffer[viewportW*y + x] = 0;
}