#!/usr/bin/env groovy
import groovy.json.JsonSlurper


File javalandContentFile = new File ("javaland.json")
//String javalandContent = javalandContentFile.readBytes().toString()

JsonSlurper javalandSlurper = new JsonSlurper()
def javaland = javalandSlurper.parse(javalandContentFile)

def speakers = javaland.speakers

println "Tweeted;Sprecher;Abstract;TwitterHandle;TwitterFragment"
speakers.each {def speaker->
    speaker.eventIds.each {def eventId->
        println ";$speaker.name;https://dukecon.org/javaland/talk.html#talk?talkId=$eventId;XXX von XXX: https://dukecon.org/javaland/talk.html#talk?talkId=$eventId w/ @DukeConference, the new @JavaLandConf App"
    }
}