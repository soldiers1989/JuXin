%Arbitrage.m
%Find an arbitrage opportunity in a set of coupon bonds
%Use [x,fval] = linprog(f,A,b)

%Copyright � 2010 John Wiley & Sons, Inc., Dessislava A. Pachamanova, and Frank J. Fabozzi.
%All rights reserved.

%Model files and code may be copied and used only by owners of the book Simulation and Optimization in Finance: Modeling with MATLAB, @RISK or VBA, by Dessislava A. Pachamanova and Frank J. Fabozzi, Hoboken, NJ: John Wiley & Sons, 2010 and only for their own personal use.  Copying and/or use for any other purpose or by any other person is prohibited. Requests for permission for other uses should be addressed to the Permissions Department, John Wiley & Sons, Inc., 111 River Street, Hoboken, NJ 07030, (201) 748-6011, fax (201) 748-6008, or online at http://www.wiley.com/go/permissions.

%While the authors and publisher have used all reasonable efforts in creating the work, the model files and the code, they make no representations or warranties with respect to the accuracy or completeness of the contents thereof, and specifically disclaim any implied warranties of merchantability or fitness for a particular purpose.  No warranty may be created or extended by sales representatives or written sales materials.  The advice and strategies contained herein may not be suitable for a particular party�s situation.  Users should consult with a professional where appropriate.  

%LIMITATION OF LIABILITY

%IN NO EVENT SHALL THE AUTHOR OR THE PUBLISHER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE WORK, THE MODEL FILES OR THE CODE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

priceVec = [102.36; 110.83; 96.94; 114.65; 96.63] ;
couponMx = [2.50 5.00 3.00 4.00 3.50; 
            2.50 5.00 3.00 4.00 3.50; 
            2.50 5.00 3.00 4.00 3.50; 
            2.50 5.00 3.00 4.00 3.50; 
            102.50 5.00 3.00 4.00 3.50;
            0 105.00 3.00 4.00 3.50; 
            0 0 103.00 4.00 3.50; 
            0 0 0 104.00 103.50]; 

[numTimePeriods,numBonds] = size(couponMx);
        
f = priceVec;
A = [-couponsMx; -ones(1,numBonds)];
b = [zeros(numTimePeriods,1);100000]; 

[alloc,objFn] = linprog(f,A,b) 