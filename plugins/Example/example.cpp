#include <QDebug>

#include "example.h"

Example::Example() {

}

void Example::speak() {
    qDebug() << "hello world!";
}
