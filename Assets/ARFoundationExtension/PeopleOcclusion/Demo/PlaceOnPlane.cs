using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

namespace ARFoundationExtension.PeopleOcclusion.Demo
{
	public class PlaceOnPlane : MonoBehaviour
	{
        [SerializeField]
        private ARRaycastManager raycastManager;

        [SerializeField]
        private GameObject prefab;

		void Update()
		{
            if(Input.touchCount > 0 && Input.touches[0].phase == TouchPhase.Began)
            {
                var hits = new List<ARRaycastHit>();
                if (raycastManager.Raycast(Input.touches[0].position, hits, TrackableType.Planes))
                {
                    Instantiate(prefab, hits[0].pose.position, Quaternion.identity);
                }
            }
		}
	}
}
