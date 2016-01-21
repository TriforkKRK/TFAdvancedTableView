Framework for advanced TableView solutions.

It is:
- framework, it has a learning curve
- powerful and flexible
- written in Objective-C
- ported to Swift with DSL

It is NOT:
- helper tool for every UITableView in your app


SAMPLE:



ARCHITECTURE:

There are two main classes:
1) TFDynamicTableViewDataSource
* It encapsulates all bolierplate UITableViewDataSource/Delegate code.
* It automatically handles cell dequeueing and configuring with a default reuse strategy (which can be changed)
* In order to work it has to be provided with:
** Data (see 2. conceptually similar to NSFetchedResultsController)
** Metadata (Cell, Header/Footer Presenters)

2) TFViewModelResultsController
* it is an implementation of ... which is conceptually based on how NSFetchedResultsController works.
* it borrows gladly from MVVM design pattern

Actions and event delivery
- Custom Responder Chain



Section
1) Supported Actions:
    - fold, unfold, toggleFolding
    - delete

Row
1)
    - delete