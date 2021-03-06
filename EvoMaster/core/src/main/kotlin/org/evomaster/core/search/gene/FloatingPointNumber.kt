package org.evomaster.core.search.gene

import org.evomaster.core.search.service.AdaptiveParameterControl
import org.evomaster.core.search.service.Randomness
import org.evomaster.core.utils.NumberCalculationUtil.calculateIncrement
import org.evomaster.core.utils.NumberCalculationUtil.valueWithPrecision
import java.math.BigDecimal
import java.math.RoundingMode
import kotlin.math.min
import kotlin.math.pow

abstract class FloatingPointNumber<T:Number>(
    name: String,
    value: T,
    min: T? = null,
    max: T? = null,
    /**
     * specified precision
     */
    val precision: Int?
) : NumberGene<T>(name, value, min, max){


    companion object{

        /**
         * @return the maximum range of the [value] that can be changed based on
         * @param direction specified direction, >0 means + and <0 means -
         * @param min the lower bound of [value]
         * @param max the upper bound of [value]
         * @param value to be further modified
         */
        fun <N:Number> getRange(direction: Double, min: N, max: N, value : N): Long {
            return if (direction > 0)
                calculateIncrement(value.toDouble(), max.toDouble()).toLong()
            else
                calculateIncrement(min.toDouble(), value.toDouble()).toLong()
        }

        /**
         * mutate double/float number
         */
        fun <N: Number> mutateFloatingPointNumber(randomness: Randomness,
                                                  sdirection: Boolean?,
                                                  maxRange: Long? = null,
                                                  apc: AdaptiveParameterControl,
                                                  value: N, smin: N, smax: N , precision: Int?): N{

            val direction = when{
                smax == value -> false
                smin == value -> true
                else -> sdirection
            }

            val gaussianDelta = getGaussianDeltaWithDirection(randomness, direction)

            val range = maxRange?:getRange(gaussianDelta, smin, smax, value)

            var res = modifyValue(randomness, value.toDouble(), delta = gaussianDelta, maxRange = range, specifiedJumpDelta = GeneUtils.getDelta(randomness, apc, range),precision == null)

            if (precision != null && getFormattedValue(value, precision) == getFormattedValue(res, precision)){
                res += (if (gaussianDelta>0) 1.0 else -1.0).times(getMinimalDelta(precision, value)!!.toDouble())
            }

            return if (res > smax.toDouble()) smax
            else if (res < smin.toDouble()) smin
            else getFormattedValue(res as N, precision)
        }

        /**
         * @param randomness
         * @param sDirection specify a direction, null means that the direction would be decided at random
         * @return direction info generated by Gaussian
         *          < 0 means - modification
         *          > 0 means + modification
         */
        fun getGaussianDeltaWithDirection(randomness: Randomness, sDirection: Boolean?) : Double{
            var gaussianDelta = randomness.nextGaussian()
            if (gaussianDelta == 0.0)
                gaussianDelta = randomness.nextGaussian()

            if (sDirection != null && ((sDirection && gaussianDelta < 0) || (!sDirection && gaussianDelta > 0))){
                gaussianDelta *= -1.0
            }

            return gaussianDelta
        }

        private fun modifyValue(randomness: Randomness, value: Double, delta: Double, maxRange: Long, specifiedJumpDelta: Int, precisionChangeable: Boolean): Double{
            val strategies = ModifyStrategy.values().filter{
                precisionChangeable || it != ModifyStrategy.REDUCE_PRECISION
            }
            return when(randomness.choose(strategies)){
                ModifyStrategy.SMALL_CHANGE-> value + min(1, maxRange) * delta
                ModifyStrategy.LARGE_JUMP -> value + specifiedJumpDelta * delta
                ModifyStrategy.REDUCE_PRECISION -> BigDecimal(value).setScale(randomness.nextInt(15), RoundingMode.HALF_EVEN).toDouble()
            }
        }

        /**
         * @return minimal delta if it has.
         * this is typically used when the precision is specified
         */
        fun <N: Number> getMinimalDelta(precision: Int?, value: N): N? {
            if (precision == null) return null
            val mdelta = 1.0/((10.0).pow(precision))
            return when (value) {
                is Double -> valueWithPrecision(mdelta, precision).toDouble() as N
                is Float -> valueWithPrecision(mdelta, precision).toFloat() as N
                else -> throw Exception("valueToFormat must be Double or Float, but it is ${value::class.java.simpleName}")
            }
        }

        /**
         * @return formatted value based on precision if it has
         */
        fun <N: Number> getFormattedValue(valueToFormat: N, precision: Int?) : N {
            if (precision == null)
                return valueToFormat
            return when (valueToFormat) {
                is Double -> valueWithPrecision(valueToFormat.toDouble(), precision).toDouble() as N
                is Float -> valueWithPrecision(valueToFormat.toDouble(), precision).toFloat() as N
                else -> throw Exception("valueToFormat must be Double or Float, but it is ${valueToFormat::class.java.simpleName}")
            }
        }
    }

    enum class ModifyStrategy{
        //for small changes
        SMALL_CHANGE,
        //for large jumps
        LARGE_JUMP,
        //to reduce precision, ie chop off digits after the "."
        REDUCE_PRECISION
    }


    private fun getMaxRange(direction: Double): Long {
        return if (!isRangeSpecified()) Long.MAX_VALUE
        else if (direction > 0)
            calculateIncrement(value.toDouble(), getMaximum().toDouble()).toLong()
        else
            calculateIncrement(getMinimum().toDouble(), value.toDouble()).toLong()
    }

    /**
     * mutate Floating Point Number in a standard way
     */
    fun mutateFloatingPointNumber(randomness: Randomness, apc: AdaptiveParameterControl): T{
        return Companion.mutateFloatingPointNumber(randomness, null, maxRange = null, apc, value, smin = getMinimum(), smax = getMaximum(), precision=precision)
    }

    /**
     * @return formatted [value] based on [precision]
     */
    fun getFormattedValue(valueToFormat: T?=null) : T{
        return Companion.getFormattedValue(valueToFormat?:value, precision)
    }

    /**
     * @return minimal changes of the [value].
     * this is typlically used when [precision] is specified
     */
    fun getMinimalDelta(): T?{
        return Companion.getMinimalDelta(precision, value)
    }

    /**
     * @return Minimum value of the gene
     */
    abstract fun getMinimum() : T

    /**
     * @return Maximum value of the gene
     */
    abstract fun getMaximum() : T

    /**
     * @return whether the gene is valid that considers
     *      1) within min..max if they are specified
     *      2) precision if it is specified
     */
    override fun isValid(): Boolean {
        return super.isValid() && (precision == null || !value.toString().contains(".") || value.toString().split(".")[1].length <= precision)
    }
}