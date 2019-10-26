Shader "Unlit/ARKitPeopleOcclusionBackground"
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
        Cull Off
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4x4 _UnityDisplayTransform;

            struct Vertex
            {
                float4 position : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct TexCoordInOut
            {
                float4 position : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct FragmentOutput
            {
                half4 color : SV_Target;
                half depth : SV_Depth;
            };

            TexCoordInOut vert (Vertex vertex)
            {
                TexCoordInOut o;
                o.position = UnityObjectToClipPos(vertex.position);

                float texX = vertex.texcoord.x;
                float texY = vertex.texcoord.y;

                o.texcoord.x = (_UnityDisplayTransform[0].x * texX + _UnityDisplayTransform[1].x * (texY) + _UnityDisplayTransform[2].x);
                o.texcoord.y = (_UnityDisplayTransform[0].y * texX + _UnityDisplayTransform[1].y * (texY) + (_UnityDisplayTransform[2].y));

                return o;
            }

            // samplers
            sampler2D _textureY;
            sampler2D _textureCbCr;
            sampler2D _textureDepth;
            sampler2D _textureStencil;

            FragmentOutput frag (TexCoordInOut i)
            {
                // sample the texture
                float2 texcoord = i.texcoord;
                float y = tex2D(_textureY, texcoord).r;
                float4 ycbcr = float4(y, tex2D(_textureCbCr, texcoord).rg, 1.0);

                const float4x4 ycbcrToRGBTransform = float4x4(
                        float4(1.0, +0.0000, +1.4020, -0.7010),
                        float4(1.0, -0.3441, -0.7141, +0.5291),
                        float4(1.0, +1.7720, +0.0000, -0.8860),
                        float4(0.0, +0.0000, +0.0000, +1.0000)
                    );

                float4 color = mul(ycbcrToRGBTransform, ycbcr);

#if !UNITY_COLORSPACE_GAMMA
                // Incoming video texture is in sRGB color space. If we are rendering in linear color space, we need to convert.
                color = float4(GammaToLinearSpace(color.xyz), color.w);
#endif // !UNITY_COLORSPACE_GAMMA

                // Calculate 0-1 depth value from meter depth value
                // Reverse of LinearEyeDepth function in UnityCG.cginc
                float depthMeter = tex2D(_textureDepth, texcoord).r;
                float depth = (1.0 - _ZBufferParams.w * depthMeter) / (depthMeter * _ZBufferParams.z);

                // Get people segmentation
                half stencil = tex2D(_textureStencil, texcoord).r;
                stencil = step(1, stencil); // Get 0 or 1

                FragmentOutput o;

                o.color = color;
                o.depth = depth * stencil; // 0 means far plane

                return o;
            }
            ENDCG
        }
    }
}
