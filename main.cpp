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

    qDebug() << "Starting app from main.cpp";

    QProcess internalServer;
    internalServer.setWorkingDirectory("./yt-ws");
    internalServer.start("node", QStringList() << "--version");
    if (!internalServer.waitForReadyRead())
        qDebug() << "Error starting internal server: " << internalServer.errorString();
        qDebug().noquote() << internalServer.readAllStandardOutput();
        qDebug() << internalServer.exitCode();
        return 1;

    qDebug() << "Loading the QML...";

    QQuickView *view = new QQuickView();
    view->setSource(QUrl("qrc:/Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    return app->exec();
}
