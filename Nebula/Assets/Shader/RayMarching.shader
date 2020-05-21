//Quelle: http://web.archive.org/web/20161031203309/http://www.blog.sirenix.net/blog/realtime-volumetric-clouds-in-unity

Shader "Custom/RayMarching"
{
	Properties
	{
		_Iterations("Iterations", Range(0, 200)) = 100
		_ViewDistance("View Distance", Range(0, 5)) = 5
		_SkyColor("Sky Color", Color) = (0.23, 0, 0.38, 0.6705883) //mein lila Ton
		_CloudHighlight("Cloud Highlight", Color) = (0.5, 0, 0.2, 0.6705883) //mein pink Ton
		_CloudAlpha("CloudAlpha", Color) = (1, 1, 1, 1)
		_CloudDensity("Cloud Density", Range(0, 0.75)) = 0.4
	}

	SubShader
	{
		Pass
		{
			Blend SrcAlpha Zero

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//https://github.com/Scrawk/GPU-Voronoi-Noise
			#include "GPUVoronoiNoise3D.cginc" 

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
			  float4 vertex : SV_POSITION;
			  float2 uv : TEXCOORD0;
			};

			float3 _CamPos;
			float3 _CamRight;
			float3 _CamUp;
			float3 _CamForward;
			float _AspectRatio;
			float _FieldOfView;

			int _Iterations;
			float4 _SkyColor;
			float4 _CloudAlpha;
			float4 _CloudHighlight;
			float _ViewDistance;
			float _CloudDensity;

			v2f vert (appdata v)
			{
			  v2f o;
			  o.vertex = UnityObjectToClipPos(v.vertex);
			  o.uv = v.uv;
			  return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = (i.uv - 0.5) * _FieldOfView;
				uv.x *= _AspectRatio;

				float3 pos = _CamPos;
				float3 ray = _CamUp * uv.y + _CamRight * uv.x + _CamForward;

      			float3 p = pos;
				float density = 0;
                
				for (float i = 0; i < _Iterations; i++)
				{
					float fade = i / _Iterations; // 0 - 1
					float alpha = smoothstep(0, _Iterations * 0.1, i) * (1 - fade) * (1 - fade); //Fade-In 0 - (max)20 + kontinuierliches Fade-Out
					float denseClouds = smoothstep(_CloudDensity, 0.75, inoise(p, 0.5));
					float lightClouds = (smoothstep(-0.25, 1.2, inoise(p*2, 0.5))-0.5f) * 0.5;

					density += (lightClouds + denseClouds) * alpha;

					p = pos + ray * fade * _ViewDistance;
				}

				return lerp(_SkyColor, _CloudHighlight, max((min(density*0.1 - 0.2, 1)),0)) + float4(_CloudAlpha.rgb * 0.5, 0) * (density / _Iterations) * 15;
		}

		ENDHLSL

		}
	}
}