/*
BaseTexture
	.rgb = Diffuse Color (Diffuse Map)
	.a = Colorization factor

NormalTexture
	.rgb = Normal vector (Normal/Bump map)
	.a = Glow factor (Light map)

SpecularTexture
	.rgb = Specular color (Specular map)
	.a = Specular power (Gloss map)

*/

string _ALAMO_RENDER_PHASE = "Opaque";
string _ALAMO_VERTEX_PROC = "Mesh";
string _ALAMO_VERTEX_TYPE = "alD3dVertNU2U3U3";
bool _ALAMO_TANGENT_SPACE = true; 
bool _ALAMO_SHADOW_VOLUME = false;


#include "BumpSpecGlowColorize.fxh"


///////////////////////////////////////////////////////
//
// Vertex Shaders
//
///////////////////////////////////////////////////////
VS_OUTPUT sph_bump_spec_glow_vs_main(VS_INPUT_MESH In)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

   	Out.Pos = mul(In.Pos,m_worldViewProj);
    Out.Tex0 = In.Tex + UVOffset;                                       
	Out.Tex1 = In.Tex + UVOffset;
	Out.Tex2 = In.Tex + UVOffset;

	// Compute the tangent-space light vector and half-angle vector for per-pixel lighting
	// Note that we are doing everything in object space here.
	float3x3 to_tangent_matrix;
	to_tangent_matrix = Compute_To_Tangent_Matrix(In.Tangent,In.Binormal,In.Normal);
	Out.LightVector = Compute_Tangent_Space_Light_Vector(m_light0ObjVector,to_tangent_matrix);
	Out.HalfAngleVector = Compute_Tangent_Space_Half_Vector(In.Pos,m_eyePosObj,m_light0ObjVector,to_tangent_matrix);

	// Fill lighting is applied per-vertex.  This must be computed in
	// world space for spherical harmonics to work.
	float3 world_pos = mul(In.Pos,m_world);
	float3 world_normal = normalize(mul(In.Normal, (float3x3)m_world));
	float3 diff_light = Sph_Compute_Diffuse_Light_Fill(world_normal);
	
	// Output final vertex lighting colors:
    Out.Diff = float4(diff_light * Diffuse.rgb * m_lightScale.rgb, m_lightScale.a);  

	// Output fog
	Out.Fog = Compute_Fog(Out.Pos.xyz);

    return Out;
}

VS_OUTPUT sph_bump_vs_main(VS_INPUT_MESH In)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

   	Out.Pos = mul(In.Pos,m_worldViewProj);
    Out.Tex0 = In.Tex + UVOffset;                                       
 	Out.Tex1 = In.Tex + UVOffset;
	Out.Tex2 = In.Tex + UVOffset;

	// Compute the tangent-space light vector
	float3x3 to_tangent_matrix;
	to_tangent_matrix = Compute_To_Tangent_Matrix(In.Tangent,In.Binormal,In.Normal);
	Out.LightVector = Compute_Tangent_Space_Light_Vector(m_light0ObjVector,to_tangent_matrix);

    // Vertex lighting, diffuse fill lights + spec for main light
	float3 world_pos = mul(In.Pos,m_world);
	float3 world_normal = normalize(mul(In.Normal, (float3x3)m_world));
	float3 diff_light = Sph_Compute_Diffuse_Light_Fill(world_normal);
	
	// Output final vertex lighting colors:
    Out.Diff = float4(diff_light * Diffuse.rgb * m_lightScale.rgb, m_lightScale.a);

	// Output fog
	Out.Fog = Compute_Fog(Out.Pos.xyz);
    
    return Out;
}


vertexshader sph_bump_spec_glow_vs_main_bin = compile vs_1_1 sph_bump_spec_glow_vs_main();
vertexshader sph_bump_vs_main_bin = compile vs_1_1 sph_bump_vs_main();
pixelshader bump_spec_glow_colorize_ps_main_bin = compile ps_2_0 bump_spec_glow_colorize_ps_main();
pixelshader bump_colorize_ps_main_bin = compile ps_2_0 bump_colorize_ps_main();


//////////////////////////////////////
// Techniques follow
//////////////////////////////////////
technique max_viewport
{
    pass max_viewport_p0
    {
        SB_START

    		// blend mode
    		ZWriteEnable = true;
    		ZFunc = LESSEQUAL;
    		DestBlend = INVSRCALPHA;
    		SrcBlend = SRCALPHA;
    	    AlphaBlendEnable = false;
        SB_END        

        // shaders 
        VertexShader = (sph_bump_spec_glow_vs_main_bin);
        PixelShader  = (bump_spec_glow_colorize_ps_main_bin);
    }  
}

technique sph_t2
<
	string LOD="DX9";
>
{
    pass sph_t2_p0
    {
        SB_START

    		// blend mode
    		ZWriteEnable = true;
    		ZFunc = LESSEQUAL;
    		DestBlend = INVSRCALPHA;
    		SrcBlend = SRCALPHA;
       		//AlphaBlendEnable = false; 
    		
        SB_END        

        // shaders 
        VertexShader = (sph_bump_spec_glow_vs_main_bin);
        PixelShader  = (bump_spec_glow_colorize_ps_main_bin);
   		AlphaBlendEnable = (m_lightScale.w < 1.0f); 

    }  
}


technique sph_t1
<
	string LOD="DX8";
>
{
    pass sph_t1_p0
    {
        SB_START

    		// blend mode
    		ZWriteEnable = true;
    		ZFunc = LESSEQUAL;
    		DestBlend = INVSRCALPHA;
    		SrcBlend = SRCALPHA;
    		
        SB_END        

        // shaders
        VertexShader = (sph_bump_vs_main_bin);
        PixelShader  = (bump_colorize_ps_main_bin);
   		AlphaBlendEnable = (m_lightScale.w < 1.0f); 

    }  
}


