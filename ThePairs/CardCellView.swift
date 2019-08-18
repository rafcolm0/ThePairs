//
//  CardCellView.swift
//  ThePairs
//
//  Created by Rafael Colon on 8/17/19.
//  Copyright © 2019 rafcolm. All rights reserved.
//

import Foundation
import UIKit

/**
 Custom UICollectionViewCell for the ViewController's main UICollectionView cells.
 */
class CardCellView: UICollectionViewCell {
    @IBOutlet weak var cardImageView: UIImageView!
    var image:UIImage?;  //generated cell image object from the web (if successful)
    var cardIndex:Int?;  //cell index within the 4x4 grid from ViewController
    var imageId:Int?;  //image id for the randomly assigned image
    weak var viewModel:ViewModel?;  //weak reference to the ViewModel to handle selection callbacks
    
    //listens to isSelected state changes
    override var isSelected: Bool {
        willSet(bool){
            /**
             For the purpose of this test, only handle card selection iff card's view model exist (card is in scope).
             In theory, this should never fail as user can not select card that is out of scope (not showing).
             */
            if let viewModel = self.viewModel{
                if(bool){
                    //card selected, "flip" card over - show card image
                    self.cardImageView.image = self.image;
                    UIView.transition(with: self.cardImageView, duration: 0.6, options: .transitionFlipFromRight, animations: nil, completion: nil);
                    //check if player just won by selecting this card
                    viewModel.checkIfPlayerWon(card: self);
                } else {
                    //"flip" the card backwards only if the player has not won
                    if(viewModel.flipCard()){
                        self.cardImageView.image = UIImage(named: "backCardSide");
                        UIView.transition(with: self.cardImageView, duration: 0.6, options: .transitionFlipFromRight, animations: nil, completion: nil);
                    }
                }
            }
        }
    }
}
