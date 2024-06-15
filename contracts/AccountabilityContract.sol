// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract AccountabilityContract {
    struct Task {
        string description;
        bool isCompleted;
    }

    Task[] public tasks;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTask(string memory _description) public onlyOwner {
        tasks.push(Task(_description, false));
    }

    function depositFunds() public payable onlyOwner {
        require(msg.value > 0, "You need to send some ether");
    }

    // Safety measure to make sure funds don't get stranded in the contract
    function withdrawFunds() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "There are no funds to withdraw");
        payable(owner).transfer(amount);
    }

    function allTasksCompleted() private view returns (bool) {
        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isCompleted) {
                return false;
            }
        }
        return true;
    }

    function clearTasks() private onlyOwner {
        delete tasks;
    }

    function completeTasks(uint256 _taskId) public onlyOwner {
        require(_taskId < tasks.length, "Task doesn't exist");
        require(!tasks[_taskId].isCompleted, "Task is already completed");

        tasks[_taskId].isCompleted = true;

        // withdraws funds and clear tasks if all tasks completed
        if (allTasksCompleted()) {
            uint256 amount = address(this).balance;
            payable(owner).transfer(amount);
            clearTasks();
        }
    }

    function getTaskCount() public view returns (uint256) {
        return tasks.length;
    }

    function getDepositAmount() public view returns (uint256) {
        return address(this).balance;
    }
}
