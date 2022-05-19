/*
 * Copyright (C) 2022  walking-octopus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * cathode-tube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>
#include <QProcess>

int main(int argc, char *argv[])
{
    QGuiApplication *app = new QGuiApplication(argc, (char**)argv);
    app->setApplicationName("cathode-tube.walking-octopus");

    qDebug() << "Starting the internal server...";

    QProcess internalServer;
    internalServer.setWorkingDirectory("./yt-ws");
    internalServer.start("./nodeJS/bin/node", QStringList() << "index.js");
    // TODO: Switch to signals for error handeling and logging
    // TODO: Wait for process start in QML splash screen through signals
    // TODO: 

    // waitForReadyRead could be used to wait, since the server prints out a message when it's ready, but that sounds like a hack.
    if (!internalServer.waitForStarted()) {
        qDebug() << "Error starting internal server: " << internalServer.errorString();
        qDebug() << "Last output: " << internalServer.readAllStandardOutput();
        qDebug() << internalServer.exitCode();
        qDebug() << internalServer.state();

        return 1;
    }

    qDebug() << "Loading the QML...";

    QQuickView *view = new QQuickView();
    view->setSource(QUrl("qrc:/Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    return app->exec();

    // TODO: Gracefully shutdown the internal server when the app is closed
}
