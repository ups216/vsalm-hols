持续交付 - 持续集成，自动化发布和自动化测试
------------------------------------------------------

在这个实验中，您和您的团队成员将完成产品从代码到上线的发布管道的建立。我们将借助TFS所提供的持续集成引擎和Release Management功能构建一条全自动的发布管道，您将可以在完成代码编写后一键发布新版本到生产环境，并在这个过程中通过测试环境完成产品功能的验证和上线审批。

我们还将使用单元测试，代码覆盖率，代码分析和自动化UI测试来提高我们对代码质量的掌控能力。

最后，我们将对发布管道中所产生的度量数据进行分析，让我们可以通过数字对代码质量进行分析和评估。

练习一：为你的项目添加持续集成能力
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TFS使用 **生成定义** 来管理项目的持续集成配置，在每一个 **团队项目** 中，可以配置多个 **生成定义** 分别对应不同的代码分支，测试环境或者团队。在这个实验中，我们支队如何配置 **生成定义** 进行描述，关于如何规划您的持续集成方案，请参考：TODO 

任务一：创建生成定义
^^^^^^^^^^^^^^^^^^^^^^

1. 使用 **诸葛亮** 的账号登陆系统，并切换至您项目的 **生成** 功能区域下，并点击左侧的 **加号** 标识

.. figure:: images/CI-Exercise-1-Add-Build-Definition.png

2. 在弹出的 **创建生成定义** 窗口中，

选择 **Visual Studio** 并点击 **下一步** 

.. figure:: images/CI-Exercise-1-Add-Build-Definition-1.png

选择 **团队项目 | 存储库 | 默认分支 | 勾选持续集成 | 默认代理池 ** 并点击 **创建**  

.. figure:: images/CI-Exercise-1-Add-Build-Definition-2.png
 
3. 对新创建的 **生成定义** 进行定制，删除下图中未出现的内容
 
.. figure:: images/CI-Exercise-1-Modify-build-definition.png
  
4. 添加 PowerShell 生成步骤 
 
.. figure:: images/CI-Exercise-1-add-powershell-task.png

5. 配置 PowerShell 生成步骤，使用 PartsUnlimited 代码库中内置的 build.ps1 脚本来进行编译

将 PowerShell 生成步骤拖放到顶端，在右侧的 Script filename 和 Arguments 中分别输入：

Script filename = build.ps1
Arguments = -BuildConfiguration $(BuildConfiguration)

.. figure:: images/CI-Exercise-1-add-powershell-task-buildscript.png

您也可以点击 Script filename 右侧的 **...* 按钮来从代码库中选择 build.ps1 这个脚本文件

.. figure:: images/CI-Exercise-1-add-powershell-task-buildscript-1.png

build.ps1 脚本内容如下：

.. code-block:: powershell

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)] [string] $BuildConfiguration
    )

    #Install dnvm
    #& scripts/Install-Dnvm.ps1

    # Restore and build projects
    & scripts/Call-Dnu.ps1 restore .\src
    & scripts/Call-Dnu.ps1 build .\src\PartsUnlimitedWebsite --configuration $BuildConfiguration
    
这个脚本中我们调用了Install-Dnvm.ps1和Call-Dnu.ps1 这两个脚本来完成.NET运行时的安装，依赖恢复(dnu restore)和编译 (dnu build)，并且脚本提供了一个叫做BuildConfiguration的参数允许我们提供不同的编译配置参数(release/debug)。

.. note:: 
    对于许多团队来说，编写一个脚本来进行编译是非常普遍的做法，就如同很多的c应用里面都有个makefile文件一样。这样做的好处是，任何开发人员获取到源代码后都可以直接执行这个脚本来完成如依赖获取，环境配置和编译的操作。
    对于一个采用敏捷开发方式的团队来说，为每一个人和每一个新的环境提供统一，简单的一键式的编译脚本非常重要，这可以大大节省开发人员和测试人员获取新的可运行环境的成本，提高效率。同时，这样做也便于我们在开发人员本地环境和持续集成环境中使用同样的方式来执行自动化，消除同步环境对效率的影响。

6. 保存新的 **生成定义** 

点击 **保存**，并在弹出的对话框中输入名称 **PartsUnlimited_masterCI**， 点击 **确定** 

.. figure:: images/CI-Exercise-1-add-powershell-task-buildscript-2.png
    
这样，我们就完成了一个最基本的 **生成定义** 的创建。这个定义中我们仅完成了编译的工作，在后续的练习中我们将添加更多的任务，如：自动化测试和打包。


任务二：运行生成
^^^^^^^^^^^^^^^^^^^^^^^^^^^


练习二: 建立产品发布管道 - 实现自动发布
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

练习三：添加自动化测试
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

练习四：配拉取请求实现质量门控制
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





