//
//  ViewController.swift
//  boutTime
//
//  Created by Alex Millius on 22.07.16.
//  Copyright © 2016 TumTum. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var boxOneView: UIView!
    @IBOutlet weak var boxTwoView: UIView!
    @IBOutlet weak var boxThreeView: UIView!
    @IBOutlet weak var boxFourView: UIView!
    @IBOutlet weak var boxInfosView: UIView!
    
    @IBOutlet weak var boxOneLabel: UILabel!
    @IBOutlet weak var boxTwoLabel: UILabel!
    @IBOutlet weak var boxThreeLabel: UILabel!
    @IBOutlet weak var boxFourLabel: UILabel!
    
    @IBOutlet weak var bottomInfoLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var yourScoreLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var nextRoundBtn: UIButton!
    @IBOutlet weak var playAgainBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    @IBOutlet weak var boxOneHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxTwoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxFourHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxThreeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxInfoHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var boxTwoUpArrowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxTwoDownArrowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxThreeUpArrowConstraint: NSLayoutConstraint!
    @IBOutlet weak var boxThreeDownArrowConstraint: NSLayoutConstraint!
    
    var correctSound:SystemSoundID = 0
    var failSound:SystemSoundID = 0
    
    var rounds = [RoundType]()
    
    let sourceFile = "Rounds"
    let typeSourceFile = ".plist"
    
    var randomIndexUsed = [Int]()
    var currentRound = Round()
    
    var timer = 0
    let timerSeconds = 1
    var numberOfRound = 0
    let numberOfRoundMax = 6
    var score = 0
    var clock = NSTimer()
    
    //var eventsInRandomOrder = [Event]()
    var currentEvents = (random:[Event](),ordered:[Event]())
    
    var userCanShake = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setBoxesHeiht(factor: 6)
        makeCornerRound(Viewradius: 5, buttonRadius: 15)
        laodAllSounds()
        selectInterface(.instruction)
        timerLbl.text = "0:\(timerSeconds)"
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        tryLoadData(nameOfFile: sourceFile, ofType: typeSourceFile)
        becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - Helper
    
    //MARK: User interract with device
    
    @IBAction func playAgainTapped() {
        score = 0
        numberOfRound = 0
        nextRound()
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (motion == UIEventSubtype.MotionShake &&  userCanShake) {
            // User was shaking the device.
            checkIfCorrect()
        }
    }
    
    @IBAction func nextRoundTapped() {
        nextRound()
    }
    
    
    //MARK: Helper Method

    func checkIfCorrect(){
        if currentRound.checkIfCorrectOrder(proposition: currentEvents.random, correct: currentEvents.ordered){
            //Correct
            selectInterface(.roundResultSuccess)
        } else {
            //Incorrect
            selectInterface(.roundResultFail)
        }
    }
    
    func nextRound(){
        
        if numberOfRound < numberOfRoundMax {
            //Reinitialize the display of the countdown
            timerLbl.text = "0:\(timerSeconds)"
            //get a random currentRound
            currentRound = getRandomRound()
            //extract the current events
            getCurrentEvents(currentRound)
            // populate the labels
            populateUIWithData(currentEvents.random)
            // Switch to the correct interface
            selectInterface(.roundInProgres)
            //Increment The number of rounds
            numberOfRound += 1
        } else {
            selectInterface(.gameResult)
        }
    }
    
    func getRandomRound() -> Round{
        //Get a random Round
        let roundWithInfo = GameControl.getRandomRound(randomIndexUsed, rounds: rounds)
        randomIndexUsed.append(roundWithInfo.randomIndex)
        return roundWithInfo.round
    }
    
    func getCurrentEvents(round:Round){
        currentEvents.ordered = round.currentCorrectOrder
        currentEvents.random = round.getEventsRandomized(round.currentCorrectOrder)
    }
    
    func populateUIWithData(events:[Event]){
        //eventsInRandomOrder = round.getEventsRandomized(round.currentCorrectOrder)
        boxOneLabel.text = events[0].title
        boxTwoLabel.text = events[1].title
        boxThreeLabel.text = events[2].title
        boxFourLabel.text = events[3].title
    }
    
    func tryLoadData(nameOfFile name:String, ofType type:String){
        do {
            let dictionary = try PlistConverter.dictionaryFromFile(name, ofType: type)
            rounds = try EventUnarchiver.eventInventoryFromDictionary(dictionary)
            
        } catch EventsError.ConversionError(let errorMessage) {
            showAlert(errorMessage)
        } catch EventsError.InvalidKey(let errorMessage) {
            showAlert(errorMessage)
        } catch EventsError.InvalidResource(let errorMessage) {
            showAlert(errorMessage)
        } catch let error{
            showAlert("Unexptected Error", message: "\(error)")
        }
    }
    
    // MARK: Time Helper Methods
    func countdown(seconds seconds: Int) {
        timer = seconds
        clock = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateTimer(){
        //Decrease the timer
        timer -= 1
        
        //Update the timerLabel
        timerLbl.text = "0:\(timer)"
        
        //If the timer reach zéro, display the correct ui and invalidate the timer.
        if timer == 0{
            clock.invalidate()
            checkIfCorrect()
        }
    }
    
    //MARK: UI Helper
    func showAlert(title: String, message: String? = nil, style: UIAlertControllerStyle = .Alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let okAction = UIAlertAction(title: "Try Again", style: .Default, handler: dismissAlert)
        
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func dismissAlert(sender: UIAlertAction) {
        tryLoadData(nameOfFile: sourceFile, ofType: typeSourceFile)
    }
    
    func makeCornerRound(Viewradius radius:CGFloat, buttonRadius:CGFloat){
        boxOneView.layer.cornerRadius = radius
        boxTwoView.layer.cornerRadius = radius
        boxThreeView.layer.cornerRadius = radius
        boxFourView.layer.cornerRadius = radius
        logoImg.layer.cornerRadius = radius
        playAgainBtn.layer.cornerRadius = buttonRadius
    }
    
    func hideBoxes(hidden:Bool){
        boxOneView.hidden = hidden
        boxTwoView.hidden = hidden
        boxThreeView.hidden = hidden
        boxFourView.hidden = hidden
        boxInfosView.hidden = hidden
    }
    
    func bottomUIRoundInProgress(hidden:Bool){
        nextRoundBtn.hidden = hidden
        timerLbl.hidden = !hidden
        bottomInfoLbl.hidden = !hidden
        infoBtn.hidden = hidden
    }
    
    func hideResultUI(hidden:Bool){
        logoImg.hidden = hidden
        yourScoreLbl.hidden = hidden
        scoreLbl.hidden = hidden
        playAgainBtn.hidden = hidden
    }
    
    enum Interfaces {
        case instruction
        case roundInProgres
        case roundResultSuccess
        case roundResultFail
        case gameResult
    }
    
    enum NextRoundImg:String {
        case next_round_success
        case next_round_fail
        
        func icon() -> UIImage {
            if let image = UIImage(named: self.rawValue){
                return image
            } else {
                return UIImage()
            }
        }
    }
    
    func selectInterface(interface:Interfaces){
        switch interface {
        case .instruction:
            //use the score Label and the play again button to display some instructions
            yourScoreLbl.text = "Welcome to the game\nClass the moovies in order of release\nYou have 60 seconds per round\nGood Luck!"
            playAgainBtn.setTitle("Let's Go !", forState: .Normal)
            hideResultUI(false)
            hideBoxes(true)
            userCanShake = false
        case .roundInProgres:
            hideResultUI(true)
            hideBoxes(false)
            bottomUIRoundInProgress(true)
            countdown(seconds: timerSeconds)
            userCanShake = true
        case .roundResultSuccess:
            hideResultUI(true)
            hideBoxes(false)
            nextRoundBtn.setImage(NextRoundImg.next_round_success.icon(), forState: .Normal)
            bottomUIRoundInProgress(false)
            playSound(correctSound)
            clock.invalidate()
            userCanShake = false
            score += 1
        case .roundResultFail:
            hideResultUI(true)
            hideBoxes(false)
            nextRoundBtn.setImage(NextRoundImg.next_round_fail.icon(), forState: .Normal)
            bottomUIRoundInProgress(false)
            playSound(failSound)
            clock.invalidate()
            userCanShake = false
        case .gameResult:
            yourScoreLbl.text = "Your Score"
            scoreLbl.text = "\(score)/\(numberOfRoundMax)"
            playAgainBtn.setTitle("Play Again", forState: .Normal)
            hideResultUI(false)
            hideBoxes(true)
            bottomUIRoundInProgress(true)
            userCanShake = false
        }
    }
    
    func setBoxesHeiht(factor factor: CGFloat){
        //Get the height of the screen and divide it by a factor to get the height of every box
        let heightOfBox = UIScreen.mainScreen().bounds.height / factor

        boxOneHeightConstraint.constant = heightOfBox
        boxTwoHeightConstraint.constant = heightOfBox
        boxThreeHeightConstraint.constant = heightOfBox
        boxFourHeightConstraint.constant = heightOfBox
        boxInfoHeightConstraint.constant = heightOfBox
        
        //Call the function to set the height of arrows in the middle boxes
        setDoubleArrowHeight(heightOfArrow: heightOfBox / 2)
    }
    
    func setDoubleArrowHeight(heightOfArrow height:CGFloat){
        boxTwoUpArrowHeightConstraint.constant = height
        boxTwoDownArrowHeightConstraint.constant = height
        boxThreeUpArrowConstraint.constant = height
        boxThreeDownArrowConstraint.constant = height
    }
    
    //MARK: sound Helper
    enum Sounds:String{
        case CorrectDing
        case IncorrectBuzz
    }
    
    func laodAllSounds(){
        let wav = "wav"
        correctSound = loadSound(correctSound, pathName: Sounds.CorrectDing.rawValue, type: wav)
        failSound = loadSound(failSound, pathName: Sounds.IncorrectBuzz.rawValue, type: wav)
    }
    
    func loadSound(systSoundId:SystemSoundID, pathName:String, type:String) -> SystemSoundID{
        var sound = SystemSoundID()
        let pathToSoundFile = NSBundle.mainBundle().pathForResource(pathName, ofType: type)
        let soundURL = NSURL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL, &sound)
        return sound
    }
    
    func playSound(soundId:SystemSoundID) {
        AudioServicesPlaySystemSound(soundId)
    }
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is InfosViewController {
            let destinationVC = segue.destinationViewController as! InfosViewController
            destinationVC.url = currentRound.infosLink
        }
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
}

