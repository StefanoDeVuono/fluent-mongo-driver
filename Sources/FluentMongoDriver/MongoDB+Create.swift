import FluentKit
import MongoKitten
import MongoCore

extension _MongoDB {
    func create(
        query: DatabaseQuery,
        onRow: @escaping (DatabaseRow) -> ()
    ) -> EventLoopFuture<Void> {
        do {
            let documents = try query.makeValueDocuments()
            
            return self.raw[query.schema]
                .insertMany(documents)
                .flatMapThrowing { reply in
                    guard reply.ok == 1, reply.insertCount == documents.count else {
                        throw FluentMongoError.insertFailed
                    }
                    
                    let reply = _MongoDBEntity(document: [
                        "insertCount": reply.insertCount
                    ], decoder: BSONDecoder())
                    onRow(reply)
                }
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
}
