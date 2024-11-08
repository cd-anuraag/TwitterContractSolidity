// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IUserProfile{
    struct UserProfile  {
        string displayName;
        string bio;
    }
    function getProfile (address _user) external view returns (UserProfile memory);
}

contract Twitter is Ownable {
    uint256 public MAX_TWEET_LENGTH = 256;
    IUserProfile profileContract;
    //address public owner;

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetLiked(address liker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);
    event TweetUnliked(address unliker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);

    modifier onlyRegisterUser(){
        IUserProfile.UserProfile memory tempUser = profileContract.getProfile(msg.sender);
        require(bytes(tempUser.displayName).length >0,"NOT REGISTERED");
        _;
    }

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping (address => Tweet[] ) public tweets;

    constructor(address _profileContract) Ownable(msg.sender){
        //msg.sender == owner;
        MAX_TWEET_LENGTH=280;
        profileContract = IUserProfile(_profileContract);
    }

    //  modifier onlyOwner(){
    //     require(msg.sender==owner,"Not an owner");
    //     _;
    //  }


    function createTweet(string memory tweet) public {
        require(bytes(tweet).length < MAX_TWEET_LENGTH,"tweet must be less than 280 characters");

        Tweet memory newTweet= Tweet ({
            id:tweets[msg.sender].length,
            author:msg.sender,
            content:tweet,
            timestamp:block.timestamp,
            likes:0
        });

        tweets[msg.sender].push(newTweet);
        emit TweetCreated(tweets[msg.sender].length, msg.sender, tweet, block.timestamp);
    }

    function likeTweet(uint256 id,address author ) external {
        require(tweets[author][id].id==id,"TWEET NOT EXIST");
        tweets[author][id].likes++;
    }

    function unlikeTweet(address author, uint256 id) external {
        require(tweets[author][id].id == id, "TWEET DOES NOT EXIST");
        require(tweets[author][id].likes > 0, "TWEET HAS NO LIKES");

        tweets[author][id].likes--;

        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes );
    }

    function getTweet( uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory ){
        return tweets[_owner];
    }

    function changeTweetLength(uint256 newLength) public onlyOwner {
        MAX_TWEET_LENGTH = newLength;
    }

    function getTotalLikes(address _user) external view returns (uint){
        uint256 totalLikes;

        for(uint i=0;i<tweets[_user].length;i++){
            totalLikes += tweets[_user][i].likes ;
        }
        return totalLikes;
    }

}
