-- Vertex

#version 430 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;
#ifdef COLOR_ARRAY
layout(location = 2) in vec4 vertexColor;
#else
// Color of the object
uniform vec4 colorGlobal;
#endif

out vec4 fragmentColor;
out vec3 fragmentNormal;
out vec3 fragmentPositonWorld;
out vec3 screenSpacePosition;

void main()
{
#ifdef COLOR_ARRAY
	fragmentColor = vertexColor;
#else
	fragmentColor = colorGlobal;
#endif
	fragmentNormal = vertexNormal;
	fragmentPositonWorld = (mMatrix * vec4(vertexPosition, 1.0)).xyz;
	screenSpacePosition = (vMatrix * mMatrix * vec4(vertexPosition, 1.0)).xyz;
	gl_Position = mvpMatrix * vec4(vertexPosition, 1.0);
}


-- Fragment

#version 430 core

in vec3 screenSpacePosition;

#ifndef DIRECT_BLIT_GATHER
#include OIT_GATHER_HEADER
#endif

in vec4 fragmentColor;
in vec3 fragmentNormal;
in vec3 fragmentPositonLocal;

#ifdef DIRECT_BLIT_GATHER
out vec4 fragColor;
#endif


#ifdef USE_SSAO
uniform sampler2D ssaoTexture;
#endif

uniform vec3 lightDirection = vec3(1.0,0.0,0.0);
uniform vec3 cameraPosition; // world space

uniform vec3 ambientColor;
uniform vec3 diffuseColor;
uniform vec3 specularColor;
uniform float specularExponent;
uniform float opacity;

void main()
{
#ifdef USE_SSAO
    // Read ambient occlusion factor from texture
    vec2 texCoord = vec2(gl_FragCoord.xy + vec2(0.5, 0.5))/textureSize(ssaoTexture, 0);
    float occlusionFactor = texture(ssaoTexture, texCoord).r;
#else
    // No ambient occlusion
    const float occlusionFactor = 1.0;
#endif

	// Pseudo Phong shading
	vec3 ambientShading = ambientColor * 0.1 * occlusionFactor;
	vec3 diffuseShading = diffuseColor * clamp(dot(fragmentNormal, lightDirection)/2.0+0.75 * occlusionFactor,
	        0.0, 1.0);
	vec3 specularShading = specularColor * specularExponent * 0.00001; // In order not to get an unused warning
	vec4 color = vec4(ambientShading + diffuseShading + specularShading, opacity * fragmentColor.a);
/*#ifdef USE_SSAO
	color = vec4(vec3(occlusionFactor, 0.0, 0.0), 1.0);
#endif*/

#ifdef DIRECT_BLIT_GATHER
	// Direct rendering
	fragColor = color;
#else
#if defined(REQUIRE_INVOCATION_INTERLOCK) && !defined(TEST_NO_INVOCATION_INTERLOCK)
	// Area of mutual exclusion for fragments mapping to the same pixel
	beginInvocationInterlockARB();
	gatherFragment(color);
	endInvocationInterlockARB();
#else
	gatherFragment(color);
#endif
#endif
}
