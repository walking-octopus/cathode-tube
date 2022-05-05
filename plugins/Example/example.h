#ifndef EXAMPLE_H
#define EXAMPLE_H

#include <QObject>

class Example: public QObject {
    Q_OBJECT

public:
    Example();
    ~Example() = default;

    Q_INVOKABLE void speak();
};

#endif
