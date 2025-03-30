Shader "Arquebus/TimeColorCutoutComplex"{
	Properties {
		_MainTex ("Main texture", 2D) = "white" {}
		_MaskTex ("Mask texture", 2D) = "black" {}
		_Color ("Color", Color) = (1,1,1,1)
		_ColorTwo ("Color Two", Color) = (1,1,1,1)
		_ColorCycleSpeed ("Color Cycle Speed", Range(0.1, 5.0)) = 1.0
		_ColorIntensity ("Color Cycle Intensity", Range(0.0, 1.0)) = 0.5
		_AgeSecs ("AgeSecs", Float) = 0
	}
	SubShader {
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent-100" "RenderType" = "Transparent" }
		Pass {
			Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent-100" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			GpuProgramID 26299
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float4 _ColorTwo;
			
			float _ColorCycleSpeed;
			float _ColorIntensity;
			float _AgeSecs;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MaskTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.color = v.color;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
				//old
/*                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
				float4 timeColor;

				
                float time = (_AgeSecs / _ColorCycleSpeed);
//				float time = _Time.y * _ColorCycleSpeed;
				
                timeColor.r = 0.5 + 0.5 * sin(time);
                timeColor.g = 0.5 + 0.5 * sin(time + 2);
                timeColor.b = 0.5 + 0.5 * sin(time + 4);
                timeColor.a = 1.0;
				
                float4 cycledColor = lerp(_Color, timeColor, _ColorIntensity);
				
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1 = inp.color * cycledColor;
                tmp2 = tex2D(_MaskTex, inp.texcoord.xy);
                tmp2.zw = float2(1.0, 1.0) - tmp2.xy;
                tmp1 = tmp2.xxxx * tmp1 + tmp2.zzzz;
                tmp2 = tmp2.yyyy * _ColorTwo + tmp2.wwww;
                tmp0 = tmp0 * tmp1;
                tmp1.x = tmp0.w * tmp2.w + -0.1;
                tmp0 = tmp2 * tmp0;
                o.sv_target = tmp0;
                tmp0.x = tmp1.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                return o;*/


    fout o;

    // sample your textures
    float4 mainTexColor = tex2D(_MainTex, inp.texcoord.xy);
    float4 maskTexColor = tex2D(_MaskTex, inp.texcoord.xy);

    float time = _AgeSecs / _ColorCycleSpeed;

    float4 timeColor;
    timeColor.r = 0.2 + 0.5 * sin(time);       // red channel cycles over time
    timeColor.g = 0.2 + 0.5 * sin(time + 2);   // green channel offset by +2
    timeColor.b = 0.2 + 0.5 * sin(time + 4);   // blue channel offset by +4
    timeColor.a = 1.0;

    // blend between base color and time-cycled color
    float4 blendedColor = lerp(_Color, timeColor, _ColorIntensity);

    // apply vertex color and blended color to the texture if necessay
    float4 finalColor = inp.color * blendedColor;

    // compute inverted mask values for blending
    float2 invertedMask = 1.0 - maskTexColor.xy; // Invert the red & green channels

    // blend the final color using the mask's red channel
    finalColor = maskTexColor.x * finalColor + invertedMask.x;

    // blend `_ColorTwo` using the mask's green channel
    float4 secondaryColor = maskTexColor.y * _ColorTwo + invertedMask.y;

    // apply the final blended color to the texture
    finalColor *= mainTexColor;

    // compute alpha adjustment for transparency handling
    float alphaAdjustment = (finalColor.w * secondaryColor.w) - 0.1;

    // apply final color adjustments
    finalColor *= secondaryColor;

    // set the output color
    o.sv_target = finalColor;

    // if the computed alpha is too low, discard the pixel
    // should never be less than 0 though anyways, so clamp it beforehand and
    // check if <= 0
    if (alphaAdjustment < 0.0)
    {
        discard;
    }
    return o;
			}
			ENDCG
		}
	}
}