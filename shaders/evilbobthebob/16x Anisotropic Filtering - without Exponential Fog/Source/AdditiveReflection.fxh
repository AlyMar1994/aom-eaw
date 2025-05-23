///////////////////////////////////////////////////////////////////////////////////////////////////
// Petroglyph Confidential Source Code -- Do Not Distribute
///////////////////////////////////////////////////////////////////////////////////////////////////
//
//          $File: //depot/Projects/StarWars/Art/Shaders/RSkinBumpColorize.fx $
//          $Author: Greg_Hjelstrom $
//          $DateTime: 2004/04/14 15:29:37 $
//          $Revision: #3 $
//
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
	
	Shared HLSL code for the Additive Reflection shaders
	
	Additive sky cube reflection.
		
*/

#include "AlamoEngine.fxh"

/////////////////////////////////////////////////////////////////////
//
// Material parameters
//
/////////////////////////////////////////////////////////////////////
float3 Color < string UIName="Color"; string UIType = "ColorSwatch"; > = {0.5f, 0.5f, 0.5f};


/////////////////////////////////////////////////////////////////////
//
// Samplers
//
/////////////////////////////////////////////////////////////////////

samplerCUBE SkyCubeSampler = sampler_state 
{ 
    texture = (m_skyCubeTexture); 
};


/////////////////////////////////////////////////////////////////////
//
// Input and Output Structures
//
/////////////////////////////////////////////////////////////////////
struct VS_INPUT_MESH
{
	float4 Pos : POSITION;
	float3 Normal : NORMAL;
	float2 Tex : TEXCOORD0;
	float4 Diff : COLOR0;
};

struct VS_INPUT_SKIN
{
	float4  Pos : POSITION;
	float4  Normal : NORMAL;		// Normal.w = skin binding
};

struct VS_OUTPUT
{
	float4  Pos : POSITION;
	float4  Diff : COLOR0;
	float3	ReflectionVector : TEXCOORD3;	// reflection vector in world space
	float  Fog : FOG;
};


/////////////////////////////////////////////////////////////////////
//
// Shared Shader Code
//
/////////////////////////////////////////////////////////////////////
half4 additive_reflect_ps11_main(VS_OUTPUT In): COLOR
{
#ifdef _MAX_
	return half4(0.2,0.2,0.2,1.0);
#endif

	half4 reflect_pixel = texCUBE(SkyCubeSampler,In.ReflectionVector);
	reflect_pixel.xyz *= In.Diff.xyz;
	return reflect_pixel;
}


