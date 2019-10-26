using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Serialization;
using UnityEngine.XR.ARFoundation;
using UnityEngine.UI;

namespace ARFoundationExtension.PeopleOcclusion
{
	[DisallowMultipleComponent]
	[RequireComponent(typeof(Camera))]
	[RequireComponent(typeof(ARCameraManager))]
	[RequireComponent(typeof(ARCameraBackground))]
	public class ARCameraOcculusion : MonoBehaviour
	{
		[SerializeField]
		private ARHumanBodyManager humanBodyManager;

		private Material material;

		const string DepthTexName = "_textureDepth";
		const string StencilTexName = "_textureStencil";

		static readonly int DepthTexId = Shader.PropertyToID(DepthTexName);
		static readonly int StencilTexId = Shader.PropertyToID(StencilTexName);

		void Start()
		{
			material = GetComponent<ARCameraBackground>().material;
		}

		private void Update()
		{
			if (humanBodyManager != null)
			{
				material.SetTexture(DepthTexId, humanBodyManager.humanDepthTexture);
				material.SetTexture(StencilTexId, humanBodyManager.humanStencilTexture);
			}
		}
	}
}
