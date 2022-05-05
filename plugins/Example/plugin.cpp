#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "example.h"

void ExamplePlugin::registerTypes(const char *uri) {
    //@uri Example
    qmlRegisterSingletonType<Example>(uri, 1, 0, "Example", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Example; });
}
