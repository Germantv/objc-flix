# Project 2 - *Flix*

**objc-flix** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **1** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] User sees an error message when there's a networking error.
- [x] Movies are displayed using a CollectionView instead of a TableView.
- [x] User can search for a movie.
- [x] All images fade in as they are loading.
- [x] User can view the large movie poster by tapping on a cell.
- [x] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [ ] Customize the selection effect of the cell.
- [ ] Customize the navigation bar.
- [ ] Customize the UI.

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1.
2.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Challenges / Errors Encountered
- Challenges when working with collection view flow layout
    - At first I had to changed **Estimated Size** from clicking Collection View in Storyboard from **Automatic** to **Custom**
    - When I changed it to **Custom** it ignored my FlowLayout configuration code in viewDidLoad so then I changed the property to **None** and it finally applied my code and my cells matched the video
    
    
- **[NSInvalidArgumentException -[NSNull length]: unrecognized selector sent to instance](https://stackoverflow.com/questions/32808377/nsinvalidargumentexception-nsnull-length-unrecognized-selector-sent-to-insta)**
    - Was getting a nil error out of nowhere - after setting breakpoints and further inspecting the data getting returned from moviesDB, I found that one movie had a nil `poster_path` and `backdrop_path`
    - Changed endpoint from /nowplaying to /upcoming to fix my issue since I wanted to move on to the optionals and the fix for this would have been an nil check
    - *Below is a screenshot of the error for future reference*

<img src='https://github.com/Germantv/objc-flix/blob/master/Screen%20Shot%202020-06-04%20at%209.34.04%20AM.png' title='Error Nil key/value' height='450' width='800' alt='error screenshot' />
    

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library

## License

    Copyright [2020] [German Flores]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
