# Mesh Loader Manual

1. StarfallEx

   * Chip's Direction
   
2. Default Chip Settings

   * The Codes that can edit or can not be edit
   
3. Default Mesh Files Setting

4. Load Mesh

5. Apply Custom Material or Decals

6. The Method of Spawn the other Mesh

7. At the end


### Warning : You must update your StarfallEx version every time, cause there would be error. (I wrote code on latest version)

# StarfallEx
First of all. before to use this chip, you should download the StarfallEx (thrgrb) on GitHub not Wire
https://github.com/thegrb93/StarfallEx

If you downloaded StarfallEx, Copy&Paste at this direction Garrysmod\garrysmod\addons so you can use StarfallEx

and, basically there's some cvar code that you should type on console
```lua
sf_mesh_triangles_max_cl 2000000 -- Increase or decrease Mesh Triangles Limit (Default is 200000)
sf_timebuffer_cl 15 -- Increase or decrease chip calculate speed
sf_timebuffer_cl_owner 15 -- Increase or decrease owners chip calculate speed
```

 ##	Chips Direction
 All of Starfall Chip is saved to ``` Garrysmod\garrysmod\data\starfall ```
 
 So, put the ``` Mesh_Loader.txt and Mesh_Default_Settings.txt ``` on that direction

if you followed this every sequence, you're ready to load

# Default Chip Settings

## The Codes that can edit or can not be edit
``` Generally you must not edit Mesh_Loader.txt ```

The contents of ``` Mesh_Default_Settings.txt ``` is configuration

![](https://dl.dropbox.com/s/00q5g2o3qbdycfp/Default%20Settings.png)

like this

at this moment, here's the code that you can edit


```lua
local name = "" --Change Mesh Loader Chips name
local meshdelay = 4 --Change Meshes Spawn Delay. (I don't recommend under 3.5)
local meshSpeed = 7 --Change each Meshes Loading Speed (The more higher values, the more loading time. 4 to 500)

["HudStatus"] = true / false,
--Indicate the Hud that how many meshes you need to render on right-hand corner

["Scale"] = Number
--Sets the meshes global scale

["URL"] = {"dropbox format"}
--Write meshes URL.

["Color"] = {"R G B A"}
--Change Color. ("R G B A". A is meaning Alpha, so the more higher value, the more visible (0 to 255))
--If you want to re-use same color that used before, Change the line and, write number to string format instead of color ex) "4" = Repeat 4, use the color that used right before

["Material"] = {"models/debug/debugwhite" / "custom 'dropbox material'"}
--Sets the Material. (Write "Material" on string format.)
--(If you want to re-use same material that used before, Change the line again and, write number to string format instead of material. ex) "4" = use the material that used right before)

["Parent"] = { [Index] = {"Specific Parent Target","Targets Parent"} }
--This is new feature. Write on [Index] Designate a hologram of some order and Specific Parent Target and Targets Parent.
--(Parent Targets name is same as the Dropbox name.) ex) [1] = {"Body 1","Move"}

```

# Default Mesh Files Setting

I'll explain on this base of Visual Studio Code

So, we can see so many of face counts, when we export our obj, on average we can load this if face counts is under the 20K. 
Precisely OBJ Files total lines can't bigger than 65535, and bigger then 60000 line, that'll be cracked on some triangles

** Warning !!! If you did multiple selection and export, you must Join the all of parts that you try to export.

So, if you export obj,

![](https://note.nulltable.xyz/uploads/upload_04d00c8b9bf3f1837195f5d790e2631a.png)

there's 2 files, but we don't need mtl (material) files. so we delete it

if you open obj file to ```notepad or Notepad++ or VSC etc.```

![](https://www.dropbox.com/s/a34yhnd6mdvuhd4/123%EC%9D%8C.png?dl=0)

이런식으로 뜨게 될것입니다.

여기서 저희가 기본적으로 바꿔줘야 할것은 o 뒤에있는 것인데요. 저희는 스타폴로 불러올 모든 obj파일을 o Draw로 바꿔줄것입니다.
그리고 그 위에 있는 mtllib... 또한 지워줄것입니다.

![](https://note.nulltable.xyz/uploads/upload_482a929dcf7fe15231122984ead05d51.png)

('Functions.blend'에 써져있는건 다 다릅니다. 굳이 똑같이 Functions.blend 로 바꿀 필요가 없습니다.)
그러면 최종적으론 이런식으로 밖에 남아있지 않을 것입니다. ('Functions.blend'에 써져있는건 다 다릅니다. 굳이 똑같이 Functions.blend 로 바꿀 필요가 없습니다.)

그럼 이제 저희는 l의 글자를 포함하는 모든 글자를 찾아서 지워낼것입니다.

모든 프로그램엔 Ctrl + F를 누르면 행 찾기가 있으니 그걸 이용해서 찾고 지워주도록 합시다.
찾기를 하여 l을 포함한 모든 글자를 다 지워줍시다. 예외적으로 ```l 123 200``` 이런식으로 나오는
경우도 있는데, 이것은 ```무조건 지워줘야 합니다. 지우지 않으면 에러가 나버립니다.```

그럼 이제 저장을 해주고, https://dropbox.com 에 올려주시면 됩니다. 저는 개인적으로 폴더를 만들고 그 안에 저장을 하는것을 추천 드립니다.

# 메쉬 불러오기

스타폴의 mesh_default_settings.txt 탭에 들어가서, ```["URL"] = {}``` 안에 URL들을
추가 시킬겁니다.
Dropbox에서 아까 올린 파일의 링크를 복사후에, 붙여넣기 해서 사용해줍니다. (링크를 수동적으로 바꾸지 않아도 자동적으로 변환 해서 인식합니다.)

이 링크를 URL에 붙여넣기 하고, Ctrl + S (저장)을 한 후에, Mesh_Loader를 소환해주시면
정상적으로 로딩이 되실겁니다.

# 커스텀 재질 / 데칼 적용하기

비행기나 레이스 차량같은 경우엔 데칼 같은경우가 심어져 있는게 대부분 입니다.
하지만 P2M에선 불가능하다는것을 알아버렸죠. 하지만, 스타폴은 모든게 가능합니다.

그저 몇가지를 추가 하면 됩니다.

일단 Mesh_Default_Settings.txt 에서 ```["Material"] = {}``` 부분에 ```{"custom Dropbox재질"}``` 라고 적어줍시다
(이 Dropbox재질 또한 수동적으로 링크를 변환 하지 않아도, 자동적으로 변환하여 적용시킵니다.)

**(사진 크기는 최소 512x512, 최대 1024x1024) 1024x1024를 추천드립니다.**

# 다른 차량 또한 소환 하기

저희가 뭐 한 차량만 파서 빌드하는것도 아니고, 여러개를 만드는 경우가 대부분일것입니다.

하지만 저는 세팅을 딱 한대만 할수 있게 간편하게 만들어놨기 때문에 여러대를 불러오지 못합니다. 하지만 몇개만 바꾸면 여러대를 불러올 수 있을것입니다.


일단 mesh_defualt_settings 의 이름을 바꿔줄겁니다. 자신이 원하는 것으로 바꿔주는데, `` 이때 ```Ctrl + S```를 누르면 절대 안됩니다. ``

![image](https://user-images.githubusercontent.com/75050481/120856278-8f146700-c5ba-11eb-8339-96eff19e247e.png)

사진에 표기된 UI 버튼을 눌러주어서 다른 이름으로 저장을 해줍니다.

그 다음에 Mesh_Loader 에 다시 들어가준 다음에 
```lua 
--@include mesh_default_settings.txt 
Settings = require("mesh_default_settings.txt")
```
이 둘의 mesh_default_settings를 자신이 바꿔준 이름으로 바꿔줍니다.

만약 ASDF로 변경을 하였다면, 
```lua
--@include ASDF.txt
Settings = require("ASDF.txt")
```
가 되겠죠.

그런 다음에 다시 다른 이름으로 저장을 눌러줍시다.

그러면 에디터창이 좀 더러워지긴 해도, 여러대의 차량을 불러오실수 있을것입니다.

# 글을 마치며

사실은 고민을 많이 했습니다. 이걸 나만 써야 하는걸까, 나 말고 다른 사람이 써보면 어떨까.
몇몇 친분이 있는 분들에게만 알려드리기엔 또 너무 차별 같아서, 결국엔 직접적으로 최대한 만드는 분들의 편의를 신경써서 칩을 구상해보았습니다. 제가 항상 이 칩을 공개해야겠다는 생각이 들기전까진 지인들에겐 "예제 응용" 이라는 말을 남겼는데, 이 칩들 또한, 오로지 예제응용으로 구성된 칩들 입니다.
사실 저도 이 스타폴 메쉬를 쓸 줄은 몰랐지만 직접 예제에 있는 드롭박스 링크에 들어가 보면서 내가 블렌더에서 내보내기 한것과는 뭐가 다른게 있는지 구분해가면서 찾아냈습니다.
이 칩을 공개해야겠다는 생각이 든 이유는, 메쉬에 대해 꺠닫게 해준 기계식흑설탕님 덕분인데 처음에 그분이 Prop2Mesh와 Sketchfab 다운로더를 선사시키지 않았다면 저희는 여전히 프롭으로 빌드를 해갔었겠죠. 
저는 이 칩으로 인해, 사람들의 모델 퀄리티가 더 높아지기를 기원 하겠습니다.

궁금하신 점이나 막힌곳 또는 버그를 찾으셨다면, GRONUERS#1231 로 직접적으로 DM을 보내주시면 알려드리겠습니다.

> **마지막으로 긴 글을 읽어주셔서 감사하고 좋은 ~~불러오기~~ 만들기 하세요 !**
