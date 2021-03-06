//-----------------------------------------
	 // NAME		: Michael Bathie
	 // STUDENT NUMBER	: 7835010
	 // COURSE		: COMP 2150
	 // INSTRUCTOR	: Mike Domaratzki
	 // ASSIGNMENT	: assignment 2
	 // QUESTION	: question 1      
	 // 
	 // REMARKS: The purpose of this program is to 
	 // use event driven simulation with the goal 
	 // of simulating a simplified emergency room.
	 //
	 //
	 //-----------------------------------------

/*
 * A2main.cpp
 * COMP 2150 Object Orientation
 * (C) Computer Science, University of Manitoba
 *
 * Main function for Assignment 2
 */

#include <iostream>
#include <cstdlib>
using namespace std;

/*===============================================================================*/
/*===================================INTERFACE===================================*/
/*===============================================================================*/
/*
 * A2Const.cpp
 * COMP 2150 Object Orientation
 * (C) Computer Science, University of Manitoba
 *
 * Static class for program constants
 */

 // interface 
 // move to A2Const.hpp if using separate compilation
class A2Const {
public:
	static const int numAssessmentNurses;
	static const int numBloodTech;
	static const int numXRayTech;
	static const int numDoctors;
	static const int bloodWorkTime;
	static const int XRayTime;

};


/*===================LIST_ITEM===================*/
 // CLASS: ListItem
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  This class is used as the general
 // data that is held within lists.
 //
 //-----------------------------------------
class ListItem {
public:
	virtual int  getPriority();
};


/*===================NODE===================*/
// CLASS: Node
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS: Conatiner used as part of the structure
 // of lists.
 //
 //-----------------------------------------
class Node {
private:
	Node* next;
	ListItem* data;

public:
	Node();
	Node(Node* nextNode, ListItem* data);
	void setNext(Node* newNext);
	Node* getNext();
	int getPriority();
};


/*===================QUEUE===================*/
// CLASS: Queue
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  Queue data structure used for 
 // lines of people.
 //
 //-----------------------------------------
class Queue {
protected:
	Node* start;
	Node* end;
public:
	Queue();
	virtual void enqueue(ListItem* data);
	void remove();
	void print();
	bool isEmpty();
};


/*===================PRIORITY_QUEUE===================*/
// CLASS: pQueue
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  Queue data structure with a priority system
 // in order to maintain the proper sequence.
 //
 //-----------------------------------------
class pQueue : public Queue {
public:
	pQueue();
	void enqueue(ListItem* data);
};


/*===================PATIENT===================*/
// CLASS: Patient
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  Structure for the patients coming 
 // to the emergency room.
 //
 //-----------------------------------------
class Patient : public ListItem {
private:
	static int identifier;
	int patientNum;
	int arrivalTime;
	int assessmentTime;
	int priority;
	char procedures[2];
	int treatmentTime;
public:
	Patient();
	Patient(int arrivalTime, int assessmentTime, int prio, char bloodWork, char xRay, int treatmentTime);
	int getPriority();
};


/*===================EVENT===================*/
// CLASS: Event
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  object containing the different
 // things that can happen in the ER.
 //
 //-----------------------------------------
class Event : public ListItem {

};


/*===================ARRIVAL===================*/
// CLASS: Arrival
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  The different ways in which a patient
 // can arrive in the ER or the stations in it.
 //
 //-----------------------------------------
class Arrival : public Event {

};

class StartAssessment : public Arrival {

};

class StartXRay : public Arrival {

};

class StartBloodWork : public Arrival {

};

class StartTreatment : public Arrival {

};


/*===================DEPARTURE===================*/
// CLASS: Departure
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  The different ways in which a patient
 // can leave the ER or stations in it.
 //
 //-----------------------------------------
class Departure : public Event {

};

class CompleteAssesment : public Departure {

};

class CompleteXRay : public Departure {

};

class CompleteBloodWork : public Departure {

};


/*===================DEPARTMENT===================*/
// CLASS: Department
 //
 // Author: Michael Bathie, 7835010
 //
 // REMARKS:  Structure that holds all of the queues
 // in the ER.
 //
 //-----------------------------------------
class Department {
private:
	AssessmentQueue* assessment;
	XRayQueue* xRay;
	BloodWorkQueue* bloodWork;
	TreatmentQueue* treatment;
public:
	Department();
};

class AssessmentQueue {

};

class XRayQueue {

};

class BloodWorkQueue {

};

class TreatmentQueue {

};


/*==========================================================================*/
/*===================================MAIN===================================*/
/*==========================================================================*/
int main(int argc, char *argv[]) {

	if (argc < 2) {
		cout << "Usage: " << argv[0] << " <file name>\n";
		exit(1);
	}
	cout << "Simulation begins...\n";
	cout << "\n...Simulation complete.\n\n";
	cout << "\nEnd of processing.\n";


	return 0;
}// main


/*====================================================================================*/
/*===================================IMPLEMENTATION===================================*/
/*====================================================================================*/

// implementation
// leave this in A2Const.cpp and un-comment the next line
//#include "A2Const.hpp"
const int A2Const::numAssessmentNurses = 2;
const int A2Const::numBloodTech = 3;
const int A2Const::numXRayTech = 1;
const int A2Const::numDoctors = 3;
const int A2Const::bloodWorkTime = 15;
const int A2Const::XRayTime = 25;


/*===================LIST_ITEM===================*/
int ListItem::getPriority() {
	cout << "error";
	return -1;
}


/*===================NODE===================*/
Node::Node() {
	this->next = NULL;
	this->data = NULL;
}

Node::Node(Node* next, ListItem* data) {
	this->next = next;
	this->data = data;
}

void Node::setNext(Node* newNext) {
	this->next = newNext;
}

Node* Node::getNext() {
	return this->next = next;
}

int Node::getPriority() {
	return data->getPriority();
}



/*===================QUEUE===================*/
Queue::Queue() {
	start = NULL;
	end = NULL;
}

void Queue::enqueue(ListItem* data) {
	//if queue is empty
	if (start == NULL) {
		start = new Node(NULL, data);
		end = start;
	}
	else {
		end->setNext(new Node(NULL, data));
		end = end->getNext();
	}
}

void Queue::remove() {
	//if queue is not empty
	if (start != NULL) {
		Node* curr = start;
		start = start->getNext();
		delete curr;
	}
}

//testing
void Queue::print() {
	Node* curr = start;

	while (curr != NULL) {
		cout << curr->getPriority() << " ";
		curr = curr->getNext();
	}
}

bool Queue::isEmpty() {
	return start == NULL;
}


/*===================PRIORITY_QUEUE===================*/
pQueue::pQueue() {
	start = NULL;
	end = NULL;
}

void pQueue::enqueue(ListItem* data) {
	//if queue is empty
	if (start == NULL) {
		start = new Node(NULL, data);
		end = start;
	}
	else {
		//keep track of current node being looked at and previous node
		Node* curr = start;
		Node* prev = NULL;

		//while not at the end of the queue
		while (curr != NULL) {
			if (curr->getPriority() < data->getPriority()) {
				prev = curr;
				curr = curr->getNext();
			}
			else
				break;
		}
		//if we got to the end of the queue
		if (curr == NULL) {
			end->setNext(new Node(NULL, data));
			end = end->getNext();
		}
		else {
			Node* newNode = new Node(curr, data);
			prev->setNext(newNode);
		}
	}
}



/*===================PATIENT===================*/
int Patient::identifier = 1;

Patient::Patient() {
	patientNum = -1;
	this->arrivalTime = -1;
	this->assessmentTime = -1;
	this->priority = -1;
	procedures[0] = '-';
	procedures[1] = '-';
	this->treatmentTime = -1;
}

Patient::Patient(int arrivalTime, int assessmentTime, int priority, char bloodWork, char xRay, int treatmentTime) {
	patientNum = identifier;
	this->arrivalTime = arrivalTime;
	this->assessmentTime = assessmentTime;
	this->priority = priority;
	procedures[0] = bloodWork;
	procedures[1] = xRay;
	this->treatmentTime = treatmentTime;
	identifier++;
}

int Patient::getPriority() {
	return priority;
}


/*===================DEPARTURE===================*/
Department::Department() {
	assessment = new AssessmentQueue();
	xRay = new XRayQueue();
	bloodWork = new BloodWorkQueue();
	treatment = new TreatmentQueue();
}
