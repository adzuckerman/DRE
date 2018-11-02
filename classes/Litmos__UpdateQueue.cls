/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/queueupdate/*')
global class UpdateQueue {
    global UpdateQueue() {

    }
    @HttpPost
    global static void createBulk(Litmos.UpdateQueue.RequestBody req) {

    }
global class RequestBody {
    global List<Litmos.QueueUpdateModel> queueModelList;
    global RequestBody() {

    }
}
}
