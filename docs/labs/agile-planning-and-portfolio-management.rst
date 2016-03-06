敏捷项目规划 – 产品规划，迭代规划和项目监控
----------------------------------------

在这个试验中，您和您的团队成员将使用TFS内置的敏捷规划工具完成产品backlog管理(包括用户故事和积压工作项2级backlog)。对于已经放入backlog的需求进行优先级排序，并按照产品发布版本进行迭代规划，将需求放入迭代形成迭代开发计划，对需求工作量进行估计并按照团队的能力进行迭代工作量规划。

我们还将模拟2-3个迭代的开发过程，由您和你的团队一起完成具体开发任务的更新，跟踪和交付。

最终，我们将使用报表对您的团队的开发过程进行监控和评估，您将可以使用自定义的报表了解在已经完成的迭代中您的团队的效率如何。

通过本次实验，您可以学到内置在TFS2015中的敏捷工具和多层级backlog管理工具，以及如何利用它们来帮助您实现在您的团队中快速规划、管理、跟踪您的工作。您将用一个具体的迭代来了解产品积压工作看板、迭代积压工作看板、任务看板来跟踪您的工作流程。我们也将简要了解针对大型团队和组织的增强工具。

练习一
~~~~~

本次练习中，您将会学到如何利用TFS2015来管理您的积压工作、创建工作项、将工作细化成任务、分配任务给指定成员、用任务看板来跟踪任务状态。本次练习中所使用的项目管理工具适用于中小型开发团队进行项目开发。

任务一：登陆TFS Web门户
^^^^^^^^^^^^^^^^^^^^^^

1.	从任务栏中打开IE浏览器并从收藏栏中打开TFS Web Portal链接。

.. figure:: images/Exercise-1-Open-TFS-Web-Portal-From-Browse.png

2.	使用用户名liubei登陆。(密码请参考快速入门的 :doc:`/getting-started/sample-project-introduction` 一节内容）

.. figure:: images/Exercise-1-Login-TFS-Web-Portal-From-Browse.png

3.	从TFS主页中，选择“浏览”按钮打开项目和团队信息。

.. figure:: images/Exercise-1-Browse-Projects-and-Teams.png

4.  选择PartsUnlimited项目和默认的团队。

.. figure:: images/Exercise-1-Select-Project-PartsUnlimited-and-default-team.png

5.	接下来会出现PartsUnlimited默认团队的主页视图。该视图提供包含各种信息的卡片组合，例如查询结果卡片、新建工作项卡片、冲刺燃尽图卡片、团队成员卡片等等。

.. figure:: images/Exercise-1-The-team-Portal-of-Project-PartsUnlimited-default-team.png

任务二：使用积压工作项进行工作
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1.	通过选择“Work”标签来导航到积压工作项界面

.. figure:: images/Exercise-1-Go-to-Backlog-UI.png

2.	产品积压工作项可以帮助我们定义那些需要做的工作。一旦你拥有一个积压工作，你可以用它来管理当工作完成或与工作项关联的事项被迁入时，测试通过时，或者其他一些相关事项发生时等事件

.. figure:: images/Exercise-1-The-Backlog-UI.png

3.	试想下当我们的团队成员被要求实现一个新的用户故事。这个用户故事可以使顾客将浏览的产品加入购物车。这个用户故事应该被设置为高优先级，因为很多客户都对这个功能提出使用要求。选择最后一行的产品积压工作项然后创建一个标题为“将产品加入购物车”的积压工作项。

.. figure:: images/Exercise-1-Create-the-ShoppingCart-service-backlog-item.png

4.	在产品积压工作列表中，工作项是按照优先级来进行排序的，高优先级位于最上面。我们刚才创建的工作项拥有高优先级，所有我们应该将它拖拽到列表的最顶端。

.. figure:: images/Exercise-1-Drag-and-Drop-backlog-item-for-list.png

5.	双击打开我们刚创建的工作项，我们可以在工作项信息界面中配置该工作项的详细信息。

6.	将该工作项指派给诸葛亮，设置状态为“已批准”，将工作量设置为8。点击”保存并关闭“按钮

.. figure:: images/Exercise-1-Edit-the-detail-information-of-backlog-item.png

7.	通过将刚创建的工作项拖拽到当前的迭代上来指定该工作项处于当前的迭代周期内。

.. figure:: images/Exercise-1-Drag-and-Drop-backlog-item-to-current-iteration.png

8.	可以在列表中检查该工作项的“迭代路径”列的值来确定该工作项是否已分配到当前迭代周期内。只有当该工作项的状态设置为“完成”时，该工作项会从该列表中消失。

.. figure:: images/Exercise-1-Check-the-backlog-item-iteration.png