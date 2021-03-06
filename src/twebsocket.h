#ifndef TWEBSOCKET_H
#define TWEBSOCKET_H

#include <QTcpSocket>
#include <QList>
#include <QByteArray>
#include <QAtomicInt>
#include <TGlobal>
#include <THttpRequestHeader>
#include "tabstractwebsocket.h"

class TWebSocketFrame;
class TSession;


class T_CORE_EXPORT TWebSocket : public QTcpSocket, public TAbstractWebSocket
{
    Q_OBJECT
public:
    TWebSocket(int socketDescriptor, const QHostAddress &address, const THttpRequestHeader &header, QObject *parent = 0);
    virtual ~TWebSocket();

    const QByteArray &socketUuid() const { return uuid; }
    int countWorkers() const;
    bool canReadRequest() const;
    void disconnect() Q_DECL_OVERRIDE;

public slots:
    void readRequest();
    void deleteLater();
    void releaseWorker();
    void sendRawData(const QByteArray &data);
    void close();

protected:
    void startWorkerForOpening(const TSession &session);
    virtual qint64 writeRawData(const QByteArray &data) Q_DECL_OVERRIDE;
    virtual QList<TWebSocketFrame> &websocketFrames() Q_DECL_OVERRIDE { return frames; }
    QList<TWebSocketFrame> frames;

signals:
    void sendByWorker(const QByteArray &data);
    void disconnectByWorker();

private:
    QByteArray uuid;
    THttpRequestHeader reqHeader;
    QByteArray recvBuffer;
    QAtomicInt myWorkerCounter;
    volatile bool deleting;

    friend class TActionThread;
    Q_DISABLE_COPY(TWebSocket)
};


inline int TWebSocket::countWorkers() const
{
#if QT_VERSION >= 0x050000
    return myWorkerCounter.load();
#else
    return (int)myWorkerCounter;
#endif
}

#endif // TWEBSOCKET_H
