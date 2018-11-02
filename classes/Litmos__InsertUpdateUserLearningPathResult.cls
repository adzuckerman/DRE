/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/userlearningpathresult/*')
global class InsertUpdateUserLearningPathResult {
    global InsertUpdateUserLearningPathResult() {

    }
    @HttpPost
    global static List<Litmos.SendRestResultModel> createBulk(Litmos.InsertUpdateUserLearningPathResult.RequestBody req) {
        return null;
    }
global class RequestBody {
    global List<Litmos.UserLearningPathResultModel> UserLearningPathResultModelList;
    global RequestBody() {

    }
}
}
