/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/program/*')
global class InsertUpdateProgram {
    global InsertUpdateProgram() {

    }
    @HttpPost
    global static List<Litmos.SendRestResultModel> createBulk(Litmos.InsertUpdateProgram.RequestBody req) {
        return null;
    }
global class RequestBody {
    global List<Litmos.ProgramModel> ProgramModelList;
    global RequestBody() {

    }
}
}
