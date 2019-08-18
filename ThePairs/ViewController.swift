//
//  ViewController.swift
//  ThePairs
//
//  Created by Rafael Colon on 8/17/19.
//  Copyright © 2019 rafcolm. All rights reserved.
//

import UIKit

/*
 Callbacks methods for the ViewModel to refresh ViewController state based on data model changes.
 */
protocol ViewControllerDelegate{
    func showErrorMessage();
    func showProgressIndicatorAnimations();
    func loadImages();
    func showWinningMessage();
}

class ViewController: UIViewController {
    @IBOutlet weak var cardCollectionView: UICollectionView!
    var viewModel:ViewModel?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.cardCollectionView.delegate = self;
        self.viewModel = ViewModel(viewDelegate: self);
        self.viewModel?.getImagesFromAPI();  //safe to chain unwrap viewModel here as it was just initialized with delegate
    }
    
    func stopProgressIndicatorAnimations() -> Void {
        self.cardCollectionView.layer.removeAllAnimations();  //stops fading in/out animations of UICollectionView
        self.cardCollectionView.alpha = 1.0;  //sets UICollectionView full visibility
    }
    
    func newGame() -> Void{
        self.viewModel!.resetGame();  //resets view model selected card (if any)
        /**
         Query images from the server: for the purposes of this app, this is redundant if the images were already queried as the images are always the same.
         Done like this to simulate dynamic images
         */
        self.viewModel!.getImagesFromAPI();
    }
    
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        self.newGame();
    }
}

extension ViewController : ViewControllerDelegate{
    /**
     Stops UICollectionView loading animations and show general error message.
     - In a real case scenario, we would have taken advantage of the customized error enum ImageApiManagerError and show more specific error messages.
     */
    func showErrorMessage(){
        self.stopProgressIndicatorAnimations();
        let alert = UIAlertController(title: "Alert", message: "Error! Try again!", preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil);
    }
    
    /*
     Starts UICollectionView fade in/out loading animations.
    */
    func showProgressIndicatorAnimations(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat,.autoreverse], animations: {
            self.cardCollectionView.alpha = 0.0;
        }, completion: nil);
    }
    
    /**
     Callback from view model to refresh UICollectionView from view model's API images iff any.
    */
    func loadImages() {
        self.stopProgressIndicatorAnimations();
        self.cardCollectionView.reloadData();
    }
    
    func showWinningMessage(){
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy);
        feedbackGenerator.impactOccurred();
        let alert = UIAlertController(title: "WINNER", message: "MATCH! You won.", preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
            //resets game
            self.newGame();
        }));
        self.present(alert, animated: true, completion: nil);
    }
}

extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.size.width / 4)-10;
        let height = (collectionView.bounds.size.height / 4)-10;
        //ensures all cells are squared size
        return CGSize(width: width, height: height);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1;
    }
}

extension ViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if API image data available, sets UICollectionView grid columns to 4
        return self.viewModel!.hasDataToReload() ? 4 : 0;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //if API image data available, sets UICollectionView grid rows to 4
        return self.viewModel!.hasDataToReload() ? 4 : 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //current cell index within the 4x4 UICollectionView grid
        let index = (2*indexPath.section) + indexPath.row;
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCellView", for: indexPath) as! CardCellView;
        cell.cardIndex = index;
        //triggers background threads for querying web image data
        self.viewModel?.loadCardImageFromWebAt(cardCell: cell);
        cell.isSelected = false;  //ensures cell is facing down
        return cell;
    }
}

