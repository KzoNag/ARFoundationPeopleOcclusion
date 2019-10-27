# ARFoundationPeopleOcclusion
Simple implementation for "People Occlusion" features of ARKit3 by using custom material of ARCameraBackground.  
It supports  LegacyRP/LWRP/URP.

## Description
Although ARHumanBodyManager added to ARFoundation v3.0.0 provides human segmented depth and stencil textures, we need to implement our own shaders that realize People Occlusion features. This repository is simple implementation of them. The shaders reference depth and stencil textures and write calculated depth value to depth buffer. The shader is used as custom material of AR Camera Background component.

## Demo
![demo](https://raw.githubusercontent.com/wiki/KzoNag/ARFoundationPeopleOcclusion/Images/PeopleOcclusionDemo.gif)

## Requirement
An official blog article about ARKit3 is [here](https://blogs.unity3d.com/jp/2019/06/06/ar-foundation-support-for-arkit-3/).  
According to this artcle, the requiments of people occlusion features are below.

```
Please note that the people occlusion features are available only on iOS devices with the A12 Bionic chip and ANE.
```

Tested environments are below.

* Unity2019.2.10f1
* AR Foundation 3.0.0-preview.4
* AR SubSystem 3.0.0-preview.4
* ARKit XR Plugin 3.0.0-preview.4
* Xcode 11.0
* iPhone 11 Pro / iOS 13.1.3

## Usage

### Step1   
Add ARHumanBodyManager component to "AR Session Origin" GameObject and set HumanSegmentationStencilMode and HumanSegmentationDepthMode to something other than Disabled.

![AR Session Origin](https://raw.githubusercontent.com/wiki/KzoNag/ARFoundationPeopleOcclusion/Images/Usage1.png)

### Step2   
Enable UseCustomMaterial of ARCameraBackground component and set PeopleOcclusionBackground material.

### Step3 
Add ARCameraOcclusion component to "AR Camera" GameObject and attach "AR Session Origin".

![AR Camera](https://raw.githubusercontent.com/wiki/KzoNag/ARFoundationPeopleOcclusion/Images/Usage2.png)

### Installation
Download Unity package from [release page](https://github.com/KzoNag/ARFoundationPeopleOcclusion/releases) and import to your project.

### Render Pipeline support
There are 3 shaders that support each Render Pipeline(Legacy/LightWeight/Universal).  
Set proper shader to PeopleOcclusionBackground material.(Legacy one is default)  

* ARKitPeopleOcclusionBackground is for Legacy.
* ARKitLWRPPeopleOcclusionBackground is for LightWeight.
* ARKitURPPeopleOcclusionBackground is for Universal.

They are based on default background shader located on *Packages/ARKit XR Plugin/Assets/Shaders*.  

**NOTE**  
LWRP one is tested on **lwrp** branch. Universal one is not enough tested.

### License
[MIT](https://github.com/KzoNag/ARFoundationPeopleOcclusion/blob/master/LICENSE)

