// SPDX-License-Identifier: Unlicense

pragma solidity >=0.6.0 <=0.8.0;

contract crowdFunding {

    // Declare Variables

    uint256 public counter;

    // Declare project struct

    struct project {

        uint256 projectID;

        string projectTitle;

        string projectDescription;

        address projectOwner;

        uint256 projectParticipationAmount;

        uint256 projectTotalFundingAmount; 

    }

    // Define a mapping that points names to their educator struct
    mapping(uint256 => project) projectMap;

    // Declare mapping to keep traking of the different contibutors donations. 
    mapping(address => mapping(uint256  => uint256)) contributionsAmount;

    // Constructor, to assign the project ID and used as a Key for the projectMap and contributionsAmount mapping. 

    constructor() public {

        counter = 0;

    }

    // Create a new project, where project owners can list a project for crowdfunding considering the attributes of the above struct.

    function createProject (//uint256 _projectID, the project ID is counter, that is auto incremented. 
        string memory _projectTitle,
        string memory _projectDescription,
        address _projectOwner,
        uint256 _projectParticipationAmount
        //uint256 _projectTotalFundingAmount initially has to be 0, so we don't ask an input for it. 
        ) public { 
        
        //Increase counter to increase the project ID, since the counter is initialize with the smart contract as 0, 
        //the first project ID will start at 1. 
        ++counter;
        
        // The project ID is assigned by the counter, starting from 1 and initially 0 funds as _projectTotalFundingAmount
        project memory newProject = project(counter, _projectTitle, _projectDescription, _projectOwner, _projectParticipationAmount, 0); 
        
        // add a value to the mapping for that address (key = counter = projectID)
        projectMap[counter] = newProject;
        
        // set project id using our project struct mapping
        projectMap[counter].projectID = counter;
        // set project title using our project struct mapping
        projectMap[counter].projectTitle = _projectTitle;
        // set project description using our project struct mapping
        projectMap[counter].projectDescription = _projectDescription;
        // set project owner using our project struct mapping
        projectMap[counter].projectOwner = _projectOwner;
        // set project participation amount using our project struct mapping, 
        // the projectParticipationAmount is that fixed amount a participant has to contribute to a project, to successfully participate
        projectMap[counter].projectParticipationAmount = _projectParticipationAmount; 
        // set project funding amount using our project struct mapping, 
        // this defines the total funding amount collected so far for that project. At the project creation this amount should be set to 0 
        projectMap[counter].projectTotalFundingAmount = 0; 

    }


    //Setter payable function, users can interact with the smart contract to fund a certain project. Once a user 
    //contributes to a certain project, the address, the projectID and the projectParticipationAmount need to be 
    //recorded on the smart contract.

    function participateToProject(uint256 _amount, uint256 _projectID) public payable{
        //Now we add the donation to the projectrecords

        // We check if the donation is at least the projectParticipationAmount fixed in the project creation. 
        if (projectMap[_projectID].projectParticipationAmount <= _amount) {

            //We add the donation to the contributionsAmount map, if there is any previous contribution we add the new amount. 
            contributionsAmount[msg.sender][_projectID] = contributionsAmount[msg.sender][_projectID] + _amount;

            //We add the donation to the projectMap map, if there is any previous funds we add the new amount. 
            projectMap[_projectID].projectTotalFundingAmount = projectMap[_projectID].projectTotalFundingAmount + _amount;
        }
        
    }


    //Getter function, where users will be able to retrieve the full details of a crowdfunding project using projectID.
    function searchForProject(uint256 _idSearch) public returns (uint256, string memory, string memory, address, uint256, uint256) {

        return(projectMap[(_idSearch)].projectID, 
                    projectMap[(_idSearch)].projectTitle, 
                    projectMap[(_idSearch)].projectDescription,
                    projectMap[(_idSearch)].projectOwner,
                    projectMap[(_idSearch)].projectParticipationAmount,
                    projectMap[(_idSearch)].projectTotalFundingAmount); 

    }

    //Getter function in which users, by inputting an address, and a projectID will be able to see the contributions made 
    //from the specific Ethereum address on a specific project.

    function retrieveContributions(address _projectContributor, uint256 _projectID) public returns (uint256){
       
        return(contributionsAmount[_projectContributor][_projectID]);

    }

    //Withdrawal function, that can be called only by a project owner on an owned project. The function will transfer
    //the current projectTotalFundingAmount of the specific project to the project’s owner wallet.

    function withdrawlFunds(uint256 _projectID) public {
        
        if (msg.sender == projectMap[_projectID].projectOwner){

            uint256 _withdrawlAmount = projectMap[_projectID].projectTotalFundingAmount;
            projectMap[_projectID].projectTotalFundingAmount = 0;

            payable(msg.sender).send(_withdrawlAmount);
            
        } 
    }

}
