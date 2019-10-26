Shader "Unlit/ARKitURPPeopleOcclusionBackground"
{
    Properties
    {
        _textureY ("TextureY", 2D) = "white" {}
        _textureCbCr ("TextureCbCr", 2D) = "black" {}
        _textureDepth ("TetureDepth", 2D) = "black" {}
        _textureStencil ("TextureStencil", 2D) = "black" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "Default"
            Tags { "LightMode" = "UniversalForward"}

            ZTest Always
            ZWrite On
            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            float4x4 _UnityDisplayTransform;

            struct VertexInput
            {
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
            };

            struct VertexOutput
            {
                half4 pos       : SV_POSITION;
                half2 uv        : TEXCOORD0;
            };

            struct FragmentOutput
            {
                half4 color : SV_Target;
                half depth : SV_Depth;
            };

            TEXTURE2D(_textureY);
            SAMPLER(sampler_textureY);
            TEXTURE2D(_textureCbCr);
            SAMPLER(sampler_textureCbCr);
            TEXTURE2D(_textureDepth);
            SAMPLER(sampler_textureDepth);
            TEXTURE2D(_textureStencil);
            SAMPLER(sampler_textureStencil);

            VertexOutput Vertex(VertexInput i)
            {
                VertexOutput o;
                o.pos = TransformObjectToHClip(i.vertex.xyz);
                o.uv.x = (_UnityDisplayTransform[0].x * i.uv.x + _UnityDisplayTransform[1].x * (i.uv.y) + _UnityDisplayTransform[2].x);
                o.uv.y = (_UnityDisplayTransform[0].y * i.uv.x + _UnityDisplayTransform[1].y * (i.uv.y) + _UnityDisplayTransform[2].y);
                return o;
            }

            FragmentOutput Fragment(VertexOutput i)
            {
                half y = SAMPLE_TEXTURE2D(_textureY, sampler_textureY, i.uv).r;
                half4 ycbcr = half4(y, SAMPLE_TEXTURE2D(_textureCbCr, sampler_textureCbCr, i.uv).rg, 1.0);

                const half4x4 ycbcrToRGBTransform = half4x4(
                    half4(1.0, +0.0000, +1.4020, -0.7010),
                    half4(1.0, -0.3441, -0.7141, +0.5291),
                    half4(1.0, +1.7720, +0.0000, -0.8860),
                    half4(0.0, +0.0000, +0.0000, +1.0000)
                );

                half4 color = mul(ycbcrToRGBTransform, ycbcr);

#if !UNITY_COLORSPACE_GAMMA
                // Incoming video texture is in sRGB color space. If we are rendering in linear color space, we need to convert.
                color = FastSRGBToLinear(color);
#endif // !UNITY_COLORSPACE_GAMMA

                // Calculate 0-1 depth value from meter depth value
                // Reverse of LinearEyeDepth function in UnityCG.cginc
                float depthMeter = SAMPLE_TEXTURE2D(_textureDepth, sampler_textureDepth, i.uv).r;
                float depth = (1.0 - _ZBufferParams.w * depthMeter) / (depthMeter * _ZBufferParams.z);

                // Get people segmentation
                half stencil = SAMPLE_TEXTURE2D(_textureStencil, sampler_textureStencil, i.uv).r;
                stencil = step(1, stencil); // Get 0 or 1

                FragmentOutput o;

                o.color = color;
                o.depth = depth * stencil; // 0 means far plane

                return o;
            }
            ENDHLSL
        }
    }
}
