﻿Shader "Arquebus/TimeColorCutout" {
	Properties {
		_MainTex ("Main texture", 2D) = "white" {}
		_Color ("Base Color", Color) = (1,1,1,1)
		_ColorCycleSpeed ("Color Cycle Speed", Range(0.1, 5.0)) = 1.0
		_ColorIntensity ("Color Cycle Intensity", Range(0.0, 1.0)) = 0.5
	}
	SubShader {
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent-100" "RenderType" = "Transparent" }
		Pass {
			Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent-100" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			GpuProgramID 13600
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
			float _ColorCycleSpeed;
			float _ColorIntensity;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
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
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 timeColor;
                
                
                float time = _Time.y * _ColorCycleSpeed;
                
                timeColor.r = 0.5 + 0.5 * sin(time);
                timeColor.g = 0.5 + 0.5 * sin(time + 2);
                timeColor.b = 0.5 + 0.5 * sin(time + 4);
                timeColor.a = 1.0;
                
                float4 cycledColor = lerp(_Color, timeColor, _ColorIntensity);
                
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0 = tmp0 * cycledColor;
                tmp1.x = tmp0.w * inp.color.w + -0.5;
                tmp0 = tmp0 * inp.color;
                o.sv_target = tmp0;
                tmp0.x = tmp1.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                return o;
			}
			ENDCG
		}
	}
}