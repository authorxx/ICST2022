package com.foo.graphql.mutation

import com.foo.graphql.mutation.type.Flower
import org.springframework.stereotype.Component
import java.util.concurrent.atomic.AtomicInteger


@Component
open class DataRepository {

    private val flowers = mutableMapOf<Int?, Flower>()

    private val counter = AtomicInteger(0)

    init {
        listOf(Flower(0, "Darcey", "Roses", "Red", 50),
                Flower(1, "Candy Prince", "Tulips", "Pink", 18),
                Flower(2, "Lily", "Lilies", "White", 30),
                Flower(3, "Lavender", "Limonium", "Purple", 25)
        ).forEach { flowers[it.id] = it }

    }

   fun allFlowers(): Collection<Flower> = flowers.values

    fun saveFlower(name: String?, type: String? , color: String?, price: Int?): Flower {
        val id = counter.getAndIncrement()
        return Flower(id, name, type, color, price)

    }

}




