//
//  ViewModel.swift
//  ThePairs
//
//  Created by Rafael Colon on 8/17/19.
//  Copyright © 2019 rafcolm. All rights reserved.
//

import Foundation
import UIKit

class ViewModel: NSObject {
    var viewDelegate:ViewControllerDelegate;
    var imagesModel:ImageResponseModel?;
    //pointer to currently flipped card - weak to prevent nil pointer exceptions in case of dequeing the cell
    weak var selectedCard:CardCellView?;
    //pointer to card that just matched current selectedCard - weak to prevent nil pointer exceptions in case of dequeing the cell
    weak var winnerCard:CardCellView?;
    
    init(viewDelegate:ViewControllerDelegate) {  //init and setup view controller delegates for this view model instance
        self.viewDelegate = viewDelegate;
    }
    
    /**
     Resets boths winner and previously selected card before reloading the card game view.
    */
    func resetGame() -> Void {
        self.selectedCard = nil;
        self.winnerCard = nil;
    }
    
    /**
     Queries API for images and perform view delegate callbacks based on API response. If success, shuffles returned images to guarantee new order and calls view delegate refresh method.  If error, calls view delegates methods to show error messages.
     */
    func getImagesFromAPI() -> Void {
        self.viewDelegate.showProgressIndicatorAnimations();
        ImageApiManager.shared.getImagesFromApi(completion: { (model, error) in
            if let _ = error{
                self.viewDelegate.showErrorMessage();
            } else if let model = model, model.images.count > 0  {
                self.imagesModel = model;
                self.imagesModel!.images.shuffle();
                self.viewDelegate.loadImages();
            } else {
                self.viewDelegate.showErrorMessage();
            }
        });
    }
    
    /**
     Determines whether there is available API data to display or not.
     - Returns: Bool true if current API model images are available; false, otherwise.
     */
    func hasDataToReload() -> Bool{
        return self.imagesModel?.images.count ?? 0 > 0;
    }
    
    /**
     Generates and returns valid image URL for API model image at index IFF any.
     - Returns: String valid image URL for API model image at index IF available; empty string if not available.
     */
    func getImageURL(index:Int) -> String{
        if let url = self.imagesModel!.images[index]["file"]{
            let cleanUrl = ImageApiManager.shared.API_URL + (url.components(separatedBy: "/").last ?? "");
            return cleanUrl;
        }
        return "";
    }
    
    /**
    Determines whether the current game ended or not.
    - This method is needed to prevent the previously selected card to flip over at the time a player clips/flips a card that matched that previously selected card.
     - Returns: Bool that checks if current winner card exist (player won already) or not (no winner yet)
    */
    func flipCard() -> Bool{
        return self.winnerCard == nil;
    }
    
    /**
     Determines whether latest selected parameter card matches the previously selected card (self.selectedCard).
     - If no previously selected card is available: do nothing, just assigned this latest selected card as the self.currentCard
     - If latest card matches previously selected card (self.currentCard): the player won, so show winning message.
     - Otherwise: flip back self.currentCard, and assign latest selected card as current self.currentCard
    */
    func checkIfPlayerWon(card:CardCellView) -> Void {
        let feedbackGenerator = UISelectionFeedbackGenerator();
        feedbackGenerator.selectionChanged();
        if(self.flipCard()){
            if let currentCard = self.selectedCard{
                if(currentCard.cardIndex! == card.cardIndex){  //same card selected, flip it back
                    card.isSelected = false;
                    self.selectedCard = nil;
                } else if(currentCard.imageId! == card.imageId!){  //different cards with same image (cards matched), player won
                    //player won, leave both cards flipped up and show message
                    self.winnerCard = card;
                    self.winnerCard!.isSelected = true;
                    currentCard.isSelected = true;
                    //show winning message 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //delay showing winning message for 1/2 second to show matching cards
                        self.viewDelegate.showWinningMessage();
                    }
                } else {  //player lost, flip previously selected card backwards
                    currentCard.isSelected = false;
                    self.selectedCard = card;
                }
            } else {
                self.selectedCard = card;
            }
        }
    }
    
    /**
     Performs background thread for querying the image's data for the parameter card cell.
     - Randomly determines which of the available API images this parameter card cell would have, and set up image values accordingly.
     - Starts background thread for generating UIImage from the web image data.
     - Once UIImage is generated, calls main UI thread again to assign UIImage to this parameter card.
     - If any error occurs in the process, makes this parameter card background color white.  In a real case scenario, a more complex error handling procedure would have taken place: query image from cached images, try again, etc.
    */
    func loadCardImageFromWebAt(cardCell:CardCellView) -> Void {
        cardCell.image = UIImage(named: "loading");  //defaults current image to placeholder while downloading
        //generates and assigned random image id from the available pool to parameter card
        let imageId = Int.random(in: 0..<self.imagesModel!.images.count);
        cardCell.imageId = imageId;
        cardCell.viewModel = self;  //assign this view model to the card's weak view model pointer to handle card selection procedures in the future
        DispatchQueue.global(qos: .userInitiated).async {  //enter background thread
            do{
                //query image data from the web
                let data:Data = try Data(contentsOf: URL(string: self.getImageURL(index: imageId))!);
                DispatchQueue.main.async {  //returns to main UI thread
                    //generate UIImage with web image data and assign to parameter card
                    let image = UIImage(data: data);
                    cardCell.image = image;
                }
            } catch{
                DispatchQueue.main.async {   //error happened while querying web image data, return to UI main thread and default parameter card
                    cardCell.cardImageView.isHidden = true;
                    cardCell.backgroundColor = UIColor.white;
                }
            }
        }
    }
}
