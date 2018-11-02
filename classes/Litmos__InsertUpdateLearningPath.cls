/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/learningpath/*')
global class InsertUpdateLearningPath {
    global InsertUpdateLearningPath() {

    }
    @HttpPost
    global static List<Litmos.SendRestResultModel> createBulk(Litmos.InsertUpdateLearningPath.RequestBody req) {
        return null;
    }
global class RequestBody {
    global List<Litmos.LearningPathModel> LearningPathModelList;
    global RequestBody() {

    }
}
}
